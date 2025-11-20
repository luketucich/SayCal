import Foundation
import Supabase
import Combine

// MARK: - Custom Errors

/// Errors that can occur during UserManager operations
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

// MARK: - UserManager

/// Manages user authentication state and profile data.
///
/// UserManager is a singleton that handles:
/// - Authentication state tracking via Supabase
/// - User profile CRUD operations
/// - Local caching via UserDefaults
/// - Onboarding flow completion
///
/// All database operations sync with local cache automatically.
/// Profile data is always stored in metric units in the database.
@MainActor
class UserManager: ObservableObject {

    // MARK: - Singleton

    static let shared = UserManager()

    private init() {
        loadCachedData()
        setupAuthListener()
    }

    // MARK: - Published Properties

    /// Whether a user is currently authenticated
    @Published private(set) var isAuthenticated: Bool = false

    /// Whether the manager is currently loading data
    @Published private(set) var isLoading: Bool = true

    /// The currently authenticated user
    @Published private(set) var currentUser: User?

    /// The current user's profile (nil if not loaded or no profile exists)
    @Published private(set) var profile: UserProfile?

    // MARK: - Private Properties

    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    private var profileCheckComplete = false

    // MARK: - Cache Keys

    private enum CacheKey {
        static let profile = "cached_user_profile"
        static let onboardingCompleted = "onboarding_completed"
    }

    // MARK: - Date Decoder

    /// Custom JSON decoder configured for Supabase date formats
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO 8601 format with fractional seconds first (Supabase default)
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
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        }
        return decoder
    }()

    // MARK: - Initialization

    /// Loads cached profile and onboarding status from UserDefaults
    private func loadCachedData() {
        profile = loadFromCache()
        print("📦 Loaded cached data on init")
    }

    // MARK: - Public API - Authentication

    /// Signs out the current user and clears all local data
    ///
    /// - Throws: Supabase auth errors if sign out fails
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

    // MARK: - Public API - Profile Management

    /// Creates a new user profile in the database and caches it locally.
    ///
    /// This method handles the complete profile creation flow:
    /// 1. Validates authenticated user exists
    /// 2. Creates profile object with provided data
    /// 3. Inserts profile into Supabase
    /// 4. Fetches back to get server-generated timestamps
    /// 5. Updates local cache
    ///
    /// - Parameters:
    ///   - userId: The authenticated user's ID
    ///   - unitsPreference: User's preferred measurement system
    ///   - sex: User's biological sex for calorie calculations
    ///   - age: User's age in years (13-120)
    ///   - heightCm: User's height in centimeters (always stored in metric)
    ///   - weightKg: User's weight in kilograms (always stored in metric)
    ///   - activityLevel: User's typical activity level
    ///   - goal: User's fitness goal (affects calorie target)
    ///   - dietaryPreferences: Optional array of dietary preferences
    ///   - allergies: Optional array of food allergies
    ///   - targetCalories: Calculated target daily calories
    ///   - carbsPercent: Percentage of calories from carbs
    ///   - fatsPercent: Percentage of calories from fats
    ///   - proteinPercent: Percentage of calories from protein
    ///
    /// - Throws: `UserManagerError.noAuthenticatedUser` if no user is signed in
    ///           `UserManagerError.databaseError` if database operation fails
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

            // Fetch back to get server-generated timestamps
            try await fetchProfileFromDatabase()

            print("✅ Profile created and synced successfully")
        } catch {
            print("❌ Failed to create profile: \(error)")
            throw UserManagerError.databaseError(error)
        }
    }

    /// Updates an existing user profile in the database.
    ///
    /// This method:
    /// 1. Validates authenticated user exists
    /// 2. Creates update payload from profile
    /// 3. Updates database
    /// 4. Fetches back to get updated timestamps
    /// 5. Updates local cache
    ///
    /// - Parameter profile: The updated profile data
    ///
    /// - Throws: `UserManagerError.noAuthenticatedUser` if no user is signed in
    ///           `UserManagerError.databaseError` if database operation fails
    func updateProfile(_ profile: UserProfile) async throws {
        guard let userId = currentUser?.id else {
            throw UserManagerError.noAuthenticatedUser
        }

        // Create update payload
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
            onboarding_completed: profile.onboardingCompleted
        )

        do {
            print("📝 Updating profile for user: \(userId)")

            // Update database
            try await client
                .from("user_profiles")
                .update(payload)
                .eq("user_id", value: userId)
                .execute()

            print("✅ Profile updated in database")

            // Fetch back to get updated timestamps
            try await fetchProfileFromDatabase()

            print("✅ Profile updated and synced successfully")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw UserManagerError.databaseError(error)
        }
    }

    /// Refreshes the user profile from the database.
    ///
    /// Forces a fresh fetch from the database, bypassing cache.
    /// Useful when you need to ensure you have the latest data.
    ///
    /// - Throws: `UserManagerError.noAuthenticatedUser` if no user is signed in
    ///           `UserManagerError.databaseError` if database operation fails
    func refreshProfile() async throws {
        guard currentUser != nil else {
            throw UserManagerError.noAuthenticatedUser
        }

        print("🔄 Explicitly refreshing profile from server")
        try await fetchProfileFromDatabase()
    }

    // MARK: - Public API - Onboarding

    /// Completes the onboarding flow by creating a user profile.
    ///
    /// This method:
    /// 1. Converts units to metric if needed (database stores everything in metric)
    /// 2. Calculates target calories and macros
    /// 3. Creates the profile
    ///
    /// - Parameter state: The onboarding state containing user input
    ///
    /// - Throws: `UserManagerError` if profile creation fails
    func completeOnboarding(with state: OnboardingState) async throws {
        guard let userId = currentUser?.id else {
            throw UserManagerError.noAuthenticatedUser
        }

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

    // MARK: - Static Utilities

    /// Calculates target daily calories using the Mifflin-St Jeor equation.
    ///
    /// The calculation:
    /// 1. Calculates BMR (Basal Metabolic Rate) based on sex, age, height, and weight
    /// 2. Multiplies by activity level to get TDEE (Total Daily Energy Expenditure)
    /// 3. Adjusts based on goal (deficit for weight loss, surplus for gain)
    /// 4. Ensures minimum safe calorie levels (1200 for females, 1500 for males)
    ///
    /// - Parameters:
    ///   - sex: Biological sex (affects BMR calculation)
    ///   - age: Age in years
    ///   - heightCm: Height in centimeters
    ///   - weightKg: Weight in kilograms
    ///   - activityLevel: Activity level (affects TDEE multiplier)
    ///   - goal: Fitness goal (affects calorie adjustment)
    ///
    /// - Returns: Target daily calories (integer)
    static func calculateTargetCalories(
        sex: Sex,
        age: Int,
        heightCm: Int,
        weightKg: Double,
        activityLevel: ActivityLevel,
        goal: Goal
    ) -> Int {
        // Mifflin-St Jeor Equation for BMR
        let bmr: Double
        if sex == .male {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) - 161
        }

        // Calculate TDEE (Total Daily Energy Expenditure)
        let tdee = bmr * activityLevel.activityMultiplier

        // Adjust based on goal
        let targetCalories = Int(tdee) + goal.calorieAdjustment

        // Ensure minimum safe calories
        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }

    /// Calculates recommended macro percentages based on fitness goal.
    ///
    /// - Parameter goal: The user's fitness goal
    ///
    /// - Returns: A tuple of (carbs, fats, protein) percentages that sum to 100
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

    // MARK: - Private - Auth State Management

    /// Sets up the authentication state listener.
    ///
    /// This listener:
    /// - Updates isAuthenticated and currentUser when auth state changes
    /// - Loads profile when user signs in
    /// - Clears cache when user signs out
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

    /// Loads user profile when authentication state changes.
    ///
    /// Strategy:
    /// - If cached profile exists and matches current user, use it
    /// - Otherwise, fetch from database
    private func loadUserProfileOnAuth() async {
        guard let userId = currentUser?.id else { return }

        // Check if cached profile is valid for current user
        if let cached = profile, cached.userId == userId {
            print("✅ Using cached profile for user: \(userId)")
            return
        }

        // Fetch from database
        print("📥 Fetching profile from database for user: \(userId)")
        do {
            try await fetchProfileFromDatabase()
        } catch {
            print("⚠️ No profile found - user needs onboarding")
        }
    }

    // MARK: - Private - Database Operations

    /// Fetches the user profile from the database and updates local state and cache.
    ///
    /// This is the single source of truth for profile data.
    /// All create/update operations should call this after modifying the database
    /// to ensure local state matches server state (especially timestamps).
    ///
    /// - Throws: `UserManagerError.noAuthenticatedUser` if no user is signed in
    ///           `UserManagerError.profileNotFound` if profile doesn't exist
    ///           `UserManagerError.databaseError` for other database errors
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

            // Decode with custom date decoder
            let profile = try decoder.decode(UserProfile.self, from: response.data)

            // Update state and cache atomically
            self.profile = profile
            saveToCache(profile)

            print("✅ Profile fetched and cached for user: \(userId)")
        } catch {
            print("❌ Failed to fetch profile: \(error)")

            // Clear profile if not found
            self.profile = nil
            UserDefaults.standard.removeObject(forKey: CacheKey.profile)

            throw UserManagerError.databaseError(error)
        }
    }

    // MARK: - Private - Cache Management

    /// Saves profile to UserDefaults cache
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

    /// Loads profile from UserDefaults cache
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

    /// Clears all cached data
    private func clearCache() {
        profile = nil
        UserDefaults.standard.removeObject(forKey: CacheKey.profile)
        UserDefaults.standard.removeObject(forKey: CacheKey.onboardingCompleted)
        print("🗑️ Cache cleared")
    }

    // MARK: - Cleanup

    deinit {
        authStateTask?.cancel()
    }
}
