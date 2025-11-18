import Foundation
import Supabase
import Combine

/// Manages authentication state and user onboarding flow
/// This class coordinates between Supabase auth and the app's onboarding process
@MainActor
class AuthManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: User?
    @Published var onboardingCompleted = false
    @Published var cachedProfile: UserProfile?

    // MARK: - Private Properties
    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    
    // UserDefaults keys
    private let onboardingCompletedKey = "onboardingCompleted"
    private let userProfileKey = "cachedUserProfile"
    
    // Create a date decoder for Supabase date format
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

    // MARK: - Initialization
    init() {
        // Load cached onboarding status from UserDefaults for immediate UI updates
        onboardingCompleted = UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        // Load cached profile from UserDefaults
        cachedProfile = loadProfileFromUserDefaults()
        setupAuthListener()
    }
    
    // MARK: - Auth State Listener
    /// Sets up a listener for authentication state changes
    /// Automatically loads onboarding status when user logs in
    private func setupAuthListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                self.isAuthenticated = state.session != nil
                self.currentUser = state.session?.user

                if let session = state.session {
                    print("User authenticated: \(session.user.id)")
                    // Refresh onboarding status from database when user logs in
                    await self.loadOnboardingStatus()
                } else {
                    print("User not authenticated")
                    // Clear onboarding status and cached profile when user logs out
                    self.onboardingCompleted = false
                    self.cachedProfile = nil
                    UserDefaults.standard.set(false, forKey: self.onboardingCompletedKey)
                    UserDefaults.standard.removeObject(forKey: self.userProfileKey)
                }

                self.isLoading = false
            }
        }
    }
    
    // MARK: - Onboarding Status Management
    /// Loads onboarding status and full profile from the database
    /// Called automatically when user logs in to sync with database state
    private func loadOnboardingStatus() async {
        guard let userId = currentUser?.id else { return }

        do {
            // Load the full profile from database
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()

            // Use the custom date decoder for the full profile
            let profile = try dateDecoder.decode(UserProfile.self, from: response.data)
            
            // Update local state and cache
            self.onboardingCompleted = profile.onboardingCompleted
            self.cachedProfile = profile
            
            // Save to UserDefaults
            UserDefaults.standard.set(profile.onboardingCompleted, forKey: onboardingCompletedKey)
            saveProfileToUserDefaults(profile)
            
            print("✅ Profile and onboarding status loaded: \(profile.onboardingCompleted)")
            
        } catch {
            print("❌ Failed to load profile: \(error)")
            
            // If there's no profile, user needs onboarding
            self.onboardingCompleted = false
            self.cachedProfile = nil
            UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
            UserDefaults.standard.removeObject(forKey: userProfileKey)
        }
    }
    
    /// Loads the full user profile from database (optional - for future use)
    /// This version properly handles date decoding
    func loadFullProfile() async -> UserProfile? {
        guard let userId = currentUser?.id else { return nil }
        
        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
            
            // Use the custom date decoder for the full profile
            let profile = try dateDecoder.decode(UserProfile.self, from: response.data)
            print("✅ Full profile loaded successfully")
            return profile
            
        } catch {
            print("❌ Failed to load full profile: \(error)")
            return nil
        }
    }
    
    /// Completes the onboarding process and creates a user profile in the database
    /// - Parameter state: The onboarding state containing all user inputs
    func completeOnboarding(with state: OnboardingState) async {
        guard let userId = currentUser?.id else { return }

        // Convert units to metric for database storage (database stores everything in metric)
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

        // Build database payload using UserProfile model
        // Target calories are calculated by OnboardingState.targetCalories computed property
        let newProfile = UserProfile(
            userId: userId,
            unitsPreference: state.unitsPreference,
            sex: state.sex,
            age: state.age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: state.activityLevel,
            dietaryPreferences: state.selectedDietaryPreferences.isEmpty ? nil : Array(state.selectedDietaryPreferences),
            allergies: state.selectedAllergies.isEmpty ? nil : Array(state.selectedAllergies),
            goal: state.goal,
            targetCalories: state.targetCalories,
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
            self.onboardingCompleted = true
            self.cachedProfile = newProfile
            
            // Save to UserDefaults
            UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
            saveProfileToUserDefaults(newProfile)

            print("✅ Profile created successfully!")
        } catch {
            print("❌ Failed to create profile: \(error)")
        }
    }
    
    // MARK: - Profile Update
    /// Updates the user profile in both the database and UserDefaults
    /// Call this method whenever the user makes changes to their profile
    /// - Parameter updatedProfile: The updated UserProfile object
    func updateProfile(_ updatedProfile: UserProfile) async throws {
        guard let userId = currentUser?.id else {
            throw NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }
        
        do {
            // Update profile in database
            try await client
                .from("user_profiles")
                .update(updatedProfile)
                .eq("user_id", value: userId)
                .execute()
            
            // Update local state and cache
            self.cachedProfile = updatedProfile
            saveProfileToUserDefaults(updatedProfile)
            
            print("✅ Profile updated successfully!")
        } catch {
            print("❌ Failed to update profile: \(error)")
            throw error
        }
    }
    
    // MARK: - UserDefaults Helpers
    /// Saves the user profile to UserDefaults
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
    
    // MARK: - Sign Out
    /// Signs out the current user and clears all local state
    func signOut() async {
        do {
            try await client.auth.signOut()
            // Clear onboarding status, cached profile, and UserDefaults
            onboardingCompleted = false
            cachedProfile = nil
            UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
            UserDefaults.standard.removeObject(forKey: userProfileKey)
            print("✅ Sign out successful")
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
    }

    deinit {
        // Cancel auth state listener when AuthManager is deallocated
        authStateTask?.cancel()
    }
}
