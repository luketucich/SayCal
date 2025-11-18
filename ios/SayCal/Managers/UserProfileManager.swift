import Foundation
import Supabase

/// Manages user profile operations including persistence, database operations, and calculations.
/// This manager is responsible for all profile-related business logic and data operations.
@MainActor
class UserProfileManager: ObservableObject {
    // MARK: - Published Properties

    /// The currently loaded user profile
    @Published var currentProfile: UserProfile?

    /// Indicates whether the user has completed onboarding
    @Published var onboardingCompleted: Bool = false

    // MARK: - Private Properties

    private let client = SupabaseManager.client

    // UserDefaults keys
    private let onboardingCompletedKey = "onboardingCompleted"
    private let userProfileKey = "cachedUserProfile"

    // MARK: - Singleton

    static let shared = UserProfileManager()

    // MARK: - Initialization

    private init() {
        // Load cached onboarding status and profile from UserDefaults
        onboardingCompleted = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        currentProfile = loadProfileFromUserDefaults()
    }

    // MARK: - Date Decoder

    /// Custom date decoder for Supabase date format
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

    // MARK: - Profile Database Operations

    /// Loads the user profile from the database
    /// - Parameter userId: The user ID to load the profile for
    /// - Returns: The loaded UserProfile, or nil if not found
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
            self.currentProfile = profile
            self.onboardingCompleted = profile.onboardingCompleted

            // Save to UserDefaults
            UserDefaults.standard.set(profile.onboardingCompleted, forKey: onboardingCompletedKey)
            saveProfileToUserDefaults(profile)

            print("✅ Profile loaded successfully for user: \(userId)")
            return profile

        } catch {
            print("❌ Failed to load profile: \(error)")

            // If there's no profile, user needs onboarding
            self.currentProfile = nil
            self.onboardingCompleted = false
            UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
            UserDefaults.standard.removeObject(forKey: userProfileKey)

            return nil
        }
    }

    /// Creates a new user profile in the database
    /// - Parameters:
    ///   - userId: The user ID for the new profile
    ///   - unitsPreference: User's preferred unit system
    ///   - sex: User's biological sex
    ///   - age: User's age
    ///   - heightCm: User's height in centimeters (always metric)
    ///   - weightKg: User's weight in kilograms (always metric)
    ///   - activityLevel: User's activity level
    ///   - goal: User's fitness goal
    ///   - dietaryPreferences: Optional dietary preferences
    ///   - allergies: Optional allergies
    ///   - targetCalories: Target daily calories
    ///   - carbsPercent: Carbohydrates percentage
    ///   - fatsPercent: Fats percentage
    ///   - proteinPercent: Protein percentage
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
            self.currentProfile = newProfile
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

    /// Updates an existing user profile in the database
    /// - Parameters:
    ///   - userId: The user ID of the profile to update
    ///   - updatedProfile: The updated UserProfile object
    func updateProfile(userId: UUID, updatedProfile: UserProfile) async throws {
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
            self.currentProfile = updatedProfile
            saveProfileToUserDefaults(updatedProfile)

            print("✅ Profile updated successfully!")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw error
        }
    }

    // MARK: - UserDefaults Persistence

    /// Saves the user profile to UserDefaults for offline access
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

    /// Loads the user profile from UserDefaults
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

    /// Clears all cached profile data from UserDefaults
    func clearCache() {
        currentProfile = nil
        onboardingCompleted = false
        UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        print("✅ Profile cache cleared")
    }

    // MARK: - Profile Calculations

    /// Calculates target calories using the Mifflin-St Jeor Equation.
    /// This is the centralized implementation used throughout the app.
    /// - Parameters:
    ///   - sex: User's biological sex
    ///   - age: User's age in years
    ///   - heightCm: User's height in centimeters (always metric)
    ///   - weightKg: User's weight in kilograms (always metric)
    ///   - activityLevel: User's activity level
    ///   - goal: User's fitness goal
    /// - Returns: Target calories per day, clamped to safe minimums
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

    /// Calculates recommended macro percentages based on user's fitness goal.
    /// Returns a tuple of (carbs%, fats%, protein%) that always sums to 100.
    /// - Parameter goal: User's fitness goal
    /// - Returns: Tuple of recommended macro percentages (carbs, fats, protein)
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

    /// Calculates target calories for a given profile
    /// - Parameter profile: The user profile
    /// - Returns: Calculated target calories
    func calculateTargetCalories(for profile: UserProfile) -> Int {
        UserProfileManager.calculateTargetCalories(
            sex: profile.sex,
            age: profile.age,
            heightCm: profile.heightCm,
            weightKg: profile.weightKg,
            activityLevel: profile.activityLevel,
            goal: profile.goal
        )
    }

    /// Calculates recommended macro percentages for a given profile
    /// - Parameter profile: The user profile
    /// - Returns: Tuple of recommended macro percentages
    func calculateMacroPercentages(for profile: UserProfile) -> (carbs: Int, fats: Int, protein: Int) {
        UserProfileManager.calculateMacroPercentages(for: profile.goal)
    }
}
