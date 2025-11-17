import Foundation
import Supabase
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: User?
    @Published var onboardingCompleted = false
    
    private let client = SupabaseManager.client
    private var authStateTask: Task<Void, Never>?
    
    init() {
        // Load onboarding status from UserDefaults on init
        onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        authStateTask = Task {
            for await state in client.auth.authStateChanges {
                self.isAuthenticated = state.session != nil
                self.currentUser = state.session?.user
                
                if let session = state.session {
                    print("User authenticated: \(session.user.id)")
                    // Refresh onboarding status when user logs in
                    await self.loadOnboardingStatus()
                } else {
                    print("User not authenticated")
                    // Clear onboarding status on logout
                    self.onboardingCompleted = false
                }
                
                self.isLoading = false
            }
        }
    }
    
    // Load onboarding status from database (call once per session)
    private func loadOnboardingStatus() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .execute()
            
            // Try to decode the profile
            let profiles = try JSONDecoder().decode([UserProfile].self, from: response.data)
            
            if let profile = profiles.first {
                // Profile exists - use its onboarding status
                self.onboardingCompleted = profile.onboardingCompleted
                UserDefaults.standard.set(profile.onboardingCompleted, forKey: "onboardingCompleted")
            } else {
                // No profile exists yet - user hasn't completed onboarding
                self.onboardingCompleted = false
                UserDefaults.standard.set(false, forKey: "onboardingCompleted")
            }
        } catch {
            print("Failed to load onboarding status: \(error)")
            // Fall back to UserDefaults value if query fails
            self.onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        }
    }
    
    // Call this when user completes onboarding
    func completeOnboarding(with state: OnboardingState) async {
        guard let userId = currentUser?.id else { return }
        
        // Convert weight to kg if using imperial
        let weightKg: Double
        if state.unitsPreference == .imperial {
            weightKg = (Double(state.weightLbs) ?? 0).lbsToKg
        } else {
            weightKg = Double(state.weightKg) ?? 0
        }
        
        // Convert height to cm if using imperial
        let heightCm: Int
        if state.unitsPreference == .imperial {
            heightCm = feetAndInchesToCm(feet: state.heightFeet, inches: state.heightInches)
        } else {
            heightCm = state.heightCm
        }
        
        // Create the profile input
        let profileInput = UserProfileInput(
            userId: userId,
            unitsPreference: state.unitsPreference,
            age: Int(state.age) ?? 0,
            heightCm: heightCm,
            weightKg: weightKg,
            workoutsPerWeek: state.workoutsPerWeek,
            activityLevel: state.activityLevel,
            dietaryPreferences: state.selectedDietaryPreferences.isEmpty ? nil : Array(state.selectedDietaryPreferences),
            allergies: state.selectedAllergies.isEmpty ? nil : Array(state.selectedAllergies),
            goal: state.goal
        )
        
        // Calculate target calories
        let targetCalories = profileInput.calculateTargetCalories(sex: state.sex)
        
        // Build an Encodable payload (no [String: Any])
        let newProfile = NewUserProfile(
            userId: userId,
            unitsPreference: state.unitsPreference,
            age: profileInput.age,
            heightCm: profileInput.heightCm,
            weightKg: profileInput.weightKg,
            workoutsPerWeek: profileInput.workoutsPerWeek,
            activityLevel: profileInput.activityLevel,
            dietaryPreferences: profileInput.dietaryPreferences,
            allergies: profileInput.allergies,
            goal: profileInput.goal,
            targetCalories: targetCalories,
            onboardingCompleted: true
        )
        
        do {
            try await client
                .from("user_profiles")
                .insert(newProfile)
                .execute()
            
            // Update local state
            self.onboardingCompleted = true
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")
            
            print("Profile created successfully!")
        } catch {
            print("Failed to create profile: \(error)")
        }
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            // Clear onboarding status on logout
            onboardingCompleted = false
            UserDefaults.standard.set(false, forKey: "onboardingCompleted")
            print("Sign out successful")
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }
    
    deinit {
        authStateTask?.cancel()
    }
}

// Encodable payload for inserting into user_profiles
private struct NewUserProfile: Encodable {
    let userId: UUID
    let unitsPreference: UnitsPreference
    let age: Int
    let heightCm: Int
    let weightKg: Double
    let workoutsPerWeek: Int
    let activityLevel: ActivityLevel
    let dietaryPreferences: [String]?
    let allergies: [String]?
    let goal: Goal
    let targetCalories: Int
    let onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case unitsPreference = "units_preference"
        case age
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case workoutsPerWeek = "workouts_per_week"
        case activityLevel = "activity_level"
        case dietaryPreferences = "dietary_preferences"
        case allergies
        case goal
        case targetCalories = "target_calories"
        case onboardingCompleted = "onboarding_completed"
    }
}
