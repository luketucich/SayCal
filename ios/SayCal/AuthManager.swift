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

    // MARK: - Private Properties
    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?

    // MARK: - Initialization
    init() {
        // Load cached onboarding status from UserDefaults for immediate UI updates
        onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
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
                    // Clear onboarding status when user logs out
                    self.onboardingCompleted = false
                }

                self.isLoading = false
            }
        }
    }
    
    // MARK: - Onboarding Status Management
    /// Loads onboarding status from the database
    /// Called automatically when user logs in to sync with database state
    private func loadOnboardingStatus() async {
        guard let userId = currentUser?.id else { return }

        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .execute()

            // Decode the user profile from database
            let profiles = try JSONDecoder().decode([UserProfile].self, from: response.data)

            if let profile = profiles.first {
                // Profile exists - sync onboarding status from database
                self.onboardingCompleted = profile.onboardingCompleted
                UserDefaults.standard.set(profile.onboardingCompleted, forKey: "onboardingCompleted")
            } else {
                // No profile exists - user needs to complete onboarding
                self.onboardingCompleted = false
                UserDefaults.standard.set(false, forKey: "onboardingCompleted")
            }
        } catch {
            print("Failed to load onboarding status: \(error)")
            // Fall back to cached value if database query fails
            self.onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
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

        // Create profile input for calorie calculation
        let profileInput = UserProfileInput(
            userId: userId,
            unitsPreference: state.unitsPreference,
            age: state.age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: state.activityLevel,
            dietaryPreferences: state.selectedDietaryPreferences.isEmpty ? nil : Array(state.selectedDietaryPreferences),
            allergies: state.selectedAllergies.isEmpty ? nil : Array(state.selectedAllergies),
            goal: state.goal
        )

        // Calculate target calories using Mifflin-St Jeor equation
        let targetCalories = profileInput.calculateTargetCalories(sex: state.sex)

        // Build database payload using UserProfile model
        let newProfile = UserProfile(
            userId: userId,
            unitsPreference: state.unitsPreference,
            sex: state.sex,
            age: profileInput.age,
            heightCm: profileInput.heightCm,
            weightKg: profileInput.weightKg,
            activityLevel: profileInput.activityLevel,
            dietaryPreferences: profileInput.dietaryPreferences,
            allergies: profileInput.allergies,
            goal: profileInput.goal,
            targetCalories: targetCalories,
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
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")

            print("Profile created successfully!")
        } catch {
            print("Failed to create profile: \(error)")
        }
    }
    
    // MARK: - Sign Out
    /// Signs out the current user and clears all local state
    func signOut() async {
        do {
            try await client.auth.signOut()
            // Clear onboarding status and cache
            onboardingCompleted = false
            UserDefaults.standard.set(false, forKey: "onboardingCompleted")
            print("Sign out successful")
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }

    deinit {
        // Cancel auth state listener when AuthManager is deallocated
        authStateTask?.cancel()
    }
}
