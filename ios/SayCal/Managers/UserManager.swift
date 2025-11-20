import Foundation
import Supabase
import Combine

@MainActor
class UserManager: ObservableObject {
    // MARK: - Published Properties

    @Published var isAuthenticated = false
    @Published private var _isLoading = true
    @Published private var profileCheckComplete = false
    @Published var currentUser: User?
    @Published var profile: UserProfile?
    @Published var onboardingCompleted: Bool = false

    var isLoading: Bool {
        _isLoading || !profileCheckComplete
    }

    // MARK: - Private Properties

    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?

    // UserDefaults keys
    private let onboardingCompletedKey = "onboardingCompleted"
    private let userProfileKey = "cachedUserProfile"

    // MARK: - Singleton

    static let shared = UserManager()

    // MARK: - Initialization

    private init() {
        // Load cached onboarding status and profile from UserDefaults
        onboardingCompleted = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        profile = loadProfileFromUserDefaults()

        setupAuthListener()
    }

    // MARK: - Date Decoder

    private lazy var dateDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO 8601 format first (most common from Supabase)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: dateString) {
                return date
            }

            // Fallback to basic ISO 8601 without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)"
            )
        }
        return decoder
    }()

    // MARK: - Auth State Listener

    private func setupAuthListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                // Reset profile check flag at the start of each auth state change
                self.profileCheckComplete = false

                self.isAuthenticated = state.session != nil
                self.currentUser = state.session?.user

                if let session = state.session {
                    print("User authenticated: \(session.user.id)")
                    // Load the user profile from the database
                    await loadUserProfile()
                } else {
                    print("User not authenticated")
                    // Clear profile data when user logs out
                    clearCache()
                }

                // Mark profile check as complete after handling auth state
                self.profileCheckComplete = true
                self._isLoading = false
            }
        }
    }

    // MARK: - Profile Loading (from Database)

    // Check cache first, only fetch from database if cache is missing or stale
    private func loadUserProfile() async {
        guard let userId = currentUser?.id else { return }

        // First check if we have a valid cached profile
        if let cached = profile, cached.userId == userId {
            // Cache is valid, no need to fetch from database
            print("✅ Using cached profile for user: \(userId)")
            return
        }

        // Only fetch from database if cache is missing or stale
        print("📥 Fetching profile from database for user: \(userId)")
        _ = await loadProfile(for: userId)
    }

    func loadProfile(for userId: UUID) async -> UserProfile? {
        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()

            // Use the custom date decoder for the profile
            let profile = try dateDecoder.decode(UserProfile.self, from: response.data)

            // Update local state and cache
            self.profile = profile
            self.onboardingCompleted = profile.onboardingCompleted

            // Save to UserDefaults
            UserDefaults.standard.set(profile.onboardingCompleted, forKey: onboardingCompletedKey)
            saveProfileToUserDefaults(profile)

            print("✅ Profile loaded successfully for user: \(userId)")
            return profile

        } catch {
            print("❌ Failed to load profile: \(error)")

            // If there's no profile, user needs onboarding
            self.profile = nil
            self.onboardingCompleted = false
            UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
            UserDefaults.standard.removeObject(forKey: userProfileKey)

            return nil
        }
    }

    func refreshProfileFromServer() async {
        guard let userId = currentUser?.id else { return }
        print("🔄 Explicitly refreshing profile from server for user: \(userId)")
        _ = await loadProfile(for: userId)
    }

    // MARK: - Profile Reading (from UserDefaults Cache)

    func getProfile() -> UserProfile? {
        return profile
    }

    func getCachedProfile() -> UserProfile? {
        return profile
    }

    // MARK: - Profile Writing (to Supabase + UserDefaults)

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
        proteinPercent: Int
    ) async throws {
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
            createdAt: nil,  // Set by database
            updatedAt: nil,  // Set by database
            onboardingCompleted: true
        )

        do {
            // Insert user profile into database
            try await client
                .from("user_profiles")
                .insert(newProfile)
                .execute()

            // Update local state and cache
            self.profile = newProfile
            self.onboardingCompleted = true

            // Save to UserDefaults
            UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
            saveProfileToUserDefaults(newProfile)

            print("✅ Profile created successfully!")
        } catch {
            print("❌ Failed to create profile: \(error)")
            throw error
        }
    }

    func updateProfile(_ updatedProfile: UserProfile) async throws {
        guard let userId = currentUser?.id else {
            throw NSError(domain: "UserManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }

        // Encodable payload to satisfy Supabase update(_:).
        // Arrays are always provided (empty when the user cleared them).
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
            let onboarding_completed: Bool
        }

        do {
            let payload = UserProfileUpdatePayload(
                units_preference: updatedProfile.unitsPreference,
                sex: updatedProfile.sex,
                age: updatedProfile.age,
                height_cm: updatedProfile.heightCm,
                weight_kg: updatedProfile.weightKg,
                activity_level: updatedProfile.activityLevel,
                dietary_preferences: updatedProfile.dietaryPreferences ?? [],
                allergies: updatedProfile.allergies ?? [],
                goal: updatedProfile.goal,
                target_calories: updatedProfile.targetCalories,
                carbs_percent: updatedProfile.carbsPercent,
                fats_percent: updatedProfile.fatsPercent,
                protein_percent: updatedProfile.proteinPercent,
                onboarding_completed: updatedProfile.onboardingCompleted
            )

            // Update profile in database using Encodable payload
            try await client
                .from("user_profiles")
                .update(payload)
                .eq("user_id", value: userId)
                .execute()

            // Update local state and cache
            self.profile = updatedProfile
            saveProfileToUserDefaults(updatedProfile)

            print("✅ Profile updated successfully!")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw error
        }
    }

    // MARK: - Onboarding

    // Database stores height/weight in metric - convert from imperial if needed
    func completeOnboarding(with state: OnboardingState) async {
        guard let userId = currentUser?.id else { return }

        // Convert to metric if needed (database stores everything in metric)
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

        // Calculate target calories and macro percentages
        let targetCalories = UserManager.calculateTargetCalories(
            sex: state.sex,
            age: state.age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: state.activityLevel,
            goal: state.goal
        )
        let macros = UserManager.calculateMacroPercentages(for: state.goal)

        // Create the profile
        do {
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
        } catch {
            print("❌ Failed to complete onboarding: \(error)")
        }
    }

    // MARK: - UserDefaults Persistence

    private func saveProfileToUserDefaults(_ profile: UserProfile) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: userProfileKey)
            print("✅ Profile saved to UserDefaults")
        } catch {
            print("❌ Failed to save profile to UserDefaults: \(error)")
        }
    }

    private func loadProfileFromUserDefaults() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: userProfileKey) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let profile = try decoder.decode(UserProfile.self, from: data)
            print("✅ Profile loaded from UserDefaults")
            return profile
        } catch {
            print("❌ Failed to load profile from UserDefaults: \(error)")
            return nil
        }
    }

    func clearCache() {
        profile = nil
        onboardingCompleted = false
        UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        print("✅ Profile cache cleared")
    }

    // MARK: - Sign Out

    func signOut() async {
        do {
            try await client.auth.signOut()
            // Clear profile cache
            clearCache()
            print("✅ Sign out successful")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Calculation Utilities (Static)

    // Centralized calorie calculation using Mifflin-St Jeor Equation
    static func calculateTargetCalories(
        sex: Sex,
        age: Int,
        heightCm: Int,
        weightKg: Double,
        activityLevel: ActivityLevel,
        goal: Goal
    ) -> Int {
        // Using Mifflin-St Jeor Equation for BMR (Basal Metabolic Rate)
        let bmr: Double
        if sex == .male {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) - 161
        }

        // Calculate TDEE (Total Daily Energy Expenditure)
        let tdee = bmr * activityLevel.activityMultiplier

        // Adjust based on goal (lose weight, maintain, gain, etc.)
        let targetCalories = Int(tdee) + goal.calorieAdjustment

        // Ensure minimum safe calories (prevents unhealthy calorie targets)
        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }

    static func calculateMacroPercentages(for goal: Goal) -> (carbs: Int, fats: Int, protein: Int) {
        switch goal {
        case .loseWeight:
            // Higher protein to preserve muscle, moderate carbs and fats
            return (carbs: 35, fats: 30, protein: 35)
        case .maintainWeight:
            // Balanced macros for maintenance
            return (carbs: 40, fats: 30, protein: 30)
        case .buildMuscle:
            // High protein for muscle growth, higher carbs for energy
            return (carbs: 40, fats: 25, protein: 35)
        case .gainWeight:
            // High carbs and protein for weight gain
            return (carbs: 45, fats: 25, protein: 30)
        }
    }

    // MARK: - Convenience Methods

    func calculateTargetCalories(for profile: UserProfile) -> Int {
        UserManager.calculateTargetCalories(
            sex: profile.sex,
            age: profile.age,
            heightCm: profile.heightCm,
            weightKg: profile.weightKg,
            activityLevel: profile.activityLevel,
            goal: profile.goal
        )
    }

    func calculateMacroPercentages(for profile: UserProfile) -> (carbs: Int, fats: Int, protein: Int) {
        UserManager.calculateMacroPercentages(for: profile.goal)
    }

    deinit {
        // Cancel auth state listener when UserManager is deallocated
        authStateTask?.cancel()
    }
}
