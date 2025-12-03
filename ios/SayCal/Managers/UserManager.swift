import Foundation
import Supabase
import Combine

enum UserManagerError: LocalizedError {
    case noAuthenticatedUser
    case profileNotFound
    case invalidProfileData
    case databaseError(Error)

    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found. Please sign in to continue."
        case .profileNotFound:
            return "User profile not found. Please complete onboarding."
        case .invalidProfileData:
            return "Profile data is invalid or corrupted."
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
}

@MainActor
class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var currentUser: User?
    @Published private(set) var profile: UserProfile?

    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    private var profileCheckComplete = false

    private enum CacheKey {
        static let profile = "cached_user_profile"
        static let onboardingCompleted = "onboarding_completed"
    }

    private init() {
        loadCachedData()
        setupAuthListener()
    }

    // Custom decoder for Supabase ISO 8601 dates
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            }

            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        }
        return decoder
    }()

    private func loadCachedData() {
        profile = loadFromCache()
        print("📦 Loaded cached data on init")
    }

    func signOut() async throws {
        do {
            try await client.auth.signOut()
            clearCache()
            print("✅ Sign out successful")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
            throw error
        }
    }

    func createProfile(
        userId: UUID,
        unitsPreference: UnitsPreference,
        sex: Sex,
        age: Int,
        heightCm: Int,
        weightKg: Double,
        activityLevel: ActivityLevel,
        goal: Goal,
        dietaryPreferences: [String]?,
        allergies: [String]?,
        targetCalories: Int,
        carbsPercent: Int,
        fatsPercent: Int,
        proteinPercent: Int,
        tier: Tier = .free
    ) async throws {
        guard currentUser != nil else {
            throw UserManagerError.noAuthenticatedUser
        }

        let newProfile = UserProfile(
            userId: userId,
            unitsPreference: unitsPreference,
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            dietaryPreferences: dietaryPreferences,
            allergies: allergies,
            goal: goal,
            targetCalories: targetCalories,
            carbsPercent: carbsPercent,
            fatsPercent: fatsPercent,
            proteinPercent: proteinPercent,
            tier: tier,
            createdAt: nil,  // Set by database
            updatedAt: nil,  // Set by database
            onboardingCompleted: true
        )

        do {
            print("📝 Creating profile for user: \(userId)")

            // Insert profile into database
            try await client
                .from("user_profiles")
                .insert(newProfile)
                .execute()

            print("✅ Profile inserted into database")

            try await fetchProfileFromDatabase()
            print("✅ Profile created and synced successfully")
        } catch {
            print("❌ Failed to create profile: \(error)")
            throw UserManagerError.databaseError(error)
        }
    }

    func updateProfile(_ profile: UserProfile) async throws {
        guard let userId = currentUser?.id else {
            throw UserManagerError.noAuthenticatedUser
        }

        struct UserProfileUpdatePayload: Encodable {
            let units_preference: UnitsPreference
            let sex: Sex
            let age: Int
            let height_cm: Int
            let weight_kg: Double
            let activity_level: ActivityLevel
            let dietary_preferences: [String]
            let allergies: [String]
            let goal: Goal
            let target_calories: Int
            let carbs_percent: Int
            let fats_percent: Int
            let protein_percent: Int
            let tier: Tier
            let onboarding_completed: Bool
        }

        let payload = UserProfileUpdatePayload(
            units_preference: profile.unitsPreference,
            sex: profile.sex,
            age: profile.age,
            height_cm: profile.heightCm,
            weight_kg: profile.weightKg,
            activity_level: profile.activityLevel,
            dietary_preferences: profile.dietaryPreferences ?? [],
            allergies: profile.allergies ?? [],
            goal: profile.goal,
            target_calories: profile.targetCalories,
            carbs_percent: profile.carbsPercent,
            fats_percent: profile.fatsPercent,
            protein_percent: profile.proteinPercent,
            tier: profile.tier,
            onboarding_completed: profile.onboardingCompleted
        )

        do {
            print("📝 Updating profile for user: \(userId)")

            try await client
                .from("user_profiles")
                .update(payload)
                .eq("user_id", value: userId)
                .execute()

            print("✅ Profile updated in database")

            try await fetchProfileFromDatabase()
            print("✅ Profile updated and synced successfully")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw UserManagerError.databaseError(error)
        }
    }

    func refreshProfile() async throws {
        guard currentUser != nil else {
            throw UserManagerError.noAuthenticatedUser
        }

        print("🔄 Refreshing profile from server")
        try await fetchProfileFromDatabase()
    }

    func completeOnboarding(with state: OnboardingState) async throws {
        guard let userId = currentUser?.id else {
            throw UserManagerError.noAuthenticatedUser
        }

        let weightKg: Double
        if state.unitsPreference == .imperial {
            weightKg = state.weightLbs.lbsToKg
        } else {
            weightKg = state.weightKg
        }

        let heightCm: Int
        if state.unitsPreference == .imperial {
            heightCm = feetAndInchesToCm(feet: state.heightFeet, inches: state.heightInches)
        } else {
            heightCm = state.heightCm
        }

        let targetCalories = UserManager.calculateTargetCalories(
            sex: state.sex,
            age: state.age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: state.activityLevel,
            goal: state.goal
        )
        let macros = UserManager.calculateMacroPercentages(for: state.goal)

        try await createProfile(
            userId: userId,
            unitsPreference: state.unitsPreference,
            sex: state.sex,
            age: state.age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: state.activityLevel,
            goal: state.goal,
            dietaryPreferences: state.selectedDietaryPreferences.isEmpty ? nil : Array(state.selectedDietaryPreferences),
            allergies: state.selectedAllergies.isEmpty ? nil : Array(state.selectedAllergies),
            targetCalories: targetCalories,
            carbsPercent: macros.carbs,
            fatsPercent: macros.fats,
            proteinPercent: macros.protein
        )
    }

    // Mifflin-St Jeor equation
    static func calculateTargetCalories(
        sex: Sex,
        age: Int,
        heightCm: Int,
        weightKg: Double,
        activityLevel: ActivityLevel,
        goal: Goal
    ) -> Int {
        let bmr: Double
        if sex == .male {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) - 161
        }

        let tdee = bmr * activityLevel.activityMultiplier
        let targetCalories = Int(tdee) + goal.calorieAdjustment
        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }

    static func calculateMacroPercentages(for goal: Goal) -> (carbs: Int, fats: Int, protein: Int) {
        switch goal {
        case .loseWeight: return (carbs: 35, fats: 30, protein: 35)
        case .maintainWeight: return (carbs: 40, fats: 30, protein: 30)
        case .buildMuscle: return (carbs: 40, fats: 25, protein: 35)
        case .gainWeight: return (carbs: 45, fats: 25, protein: 30)
        }
    }

    private func setupAuthListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                self.isAuthenticated = state.session != nil
                self.currentUser = state.session?.user

                if let session = state.session {
                    print("🔐 User authenticated: \(session.user.id)")
                    await loadUserProfileOnAuth()
                } else {
                    print("🚪 User not authenticated")
                    clearCache()
                }

                self.profileCheckComplete = true
                self.isLoading = false
            }
        }
    }

    private func loadUserProfileOnAuth() async {
        guard let userId = currentUser?.id else { return }

        if let cached = profile, cached.userId == userId {
            print("✅ Using cached profile for user: \(userId)")
            return
        }

        print("📥 Fetching profile from database for user: \(userId)")
        do {
            try await fetchProfileFromDatabase()
        } catch {
            print("⚠️ No profile found - user needs onboarding")
        }
    }

    private func fetchProfileFromDatabase() async throws {
        guard let userId = currentUser?.id else {
            throw UserManagerError.noAuthenticatedUser
        }

        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()

            let profile = try decoder.decode(UserProfile.self, from: response.data)
            self.profile = profile
            saveToCache(profile)

            print("✅ Profile fetched and cached for user: \(userId)")
        } catch {
            print("❌ Failed to fetch profile: \(error)")

            self.profile = nil
            UserDefaults.standard.removeObject(forKey: CacheKey.profile)
            throw UserManagerError.databaseError(error)
        }
    }

    private func saveToCache(_ profile: UserProfile) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: CacheKey.profile)
            print("💾 Profile saved to cache")
        } catch {
            print("❌ Failed to save profile to cache: \(error)")
        }
    }

    private func loadFromCache() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: CacheKey.profile) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let profile = try decoder.decode(UserProfile.self, from: data)
            print("💾 Profile loaded from cache")
            return profile
        } catch {
            print("❌ Failed to load profile from cache: \(error)")
            return nil
        }
    }

    private func clearCache() {
        profile = nil
        UserDefaults.standard.removeObject(forKey: CacheKey.profile)
        UserDefaults.standard.removeObject(forKey: CacheKey.onboardingCompleted)
        print("🗑️ Cache cleared")
    }

    deinit {
        authStateTask?.cancel()
    }
}
