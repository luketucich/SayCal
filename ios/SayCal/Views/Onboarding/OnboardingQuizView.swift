import SwiftUI

struct OnboardingQuizView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var profileManager = ProfileManager()

    @State private var currentStep = 1
    @State private var showError = false
    @State private var errorMessage = ""

    // Form data
    @State private var age = ""
    @State private var heightCm = ""
    @State private var weightKg = ""
    @State private var sex: Sex?
    @State private var unitsPreference: UnitsPreference = .metric
    @State private var workoutsPerWeek = 0
    @State private var activityLevel: ActivityLevel?
    @State private var goal: Goal?
    @State private var dietaryPreferences: Set<String> = []
    @State private var allergies: Set<String> = []

    private let totalSteps = 4

    var canContinue: Bool {
        switch currentStep {
        case 1:
            return basicInfoIsValid
        case 2:
            return activityLevel != nil
        case 3:
            return goal != nil
        case 4:
            return true // Dietary is optional
        default:
            return false
        }
    }

    private var basicInfoIsValid: Bool {
        guard let ageInt = Int(age), ageInt >= 13 && ageInt <= 120 else { return false }

        if unitsPreference == .metric {
            guard let height = Double(heightCm), height >= 100 && height <= 250 else { return false }
            guard let weight = Double(weightKg), weight >= 30 && weight <= 300 else { return false }
        } else {
            guard let heightInches = Double(heightCm), heightInches >= 48 && heightInches <= 96 else { return false }
            guard let weightLbs = Double(weightKg), weightLbs >= 66 && weightLbs <= 660 else { return false }
        }

        return sex != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                QuizProgressBar(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                // Current step content
                Group {
                    switch currentStep {
                    case 1:
                        BasicInfoStepView(
                            age: $age,
                            heightCm: $heightCm,
                            weightKg: $weightKg,
                            sex: $sex,
                            unitsPreference: $unitsPreference
                        )
                    case 2:
                        ActivityStepView(
                            workoutsPerWeek: $workoutsPerWeek,
                            activityLevel: $activityLevel
                        )
                    case 3:
                        GoalStepView(goal: $goal)
                    case 4:
                        DietaryStepView(
                            dietaryPreferences: $dietaryPreferences,
                            allergies: $allergies
                        )
                    default:
                        EmptyView()
                    }
                }

                Spacer()

                // Navigation buttons
                QuizNavigationButtons(
                    canGoBack: currentStep > 1,
                    canContinue: canContinue,
                    isLastStep: currentStep == totalSteps,
                    isLoading: profileManager.isLoading,
                    onBack: goBack,
                    onNext: goNext
                )
            }
            .navigationTitle("Welcome to SayCal")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func goBack() {
        withAnimation {
            currentStep = max(1, currentStep - 1)
        }
    }

    private func goNext() {
        if currentStep < totalSteps {
            withAnimation {
                currentStep += 1
            }
        } else {
            // Submit the quiz
            Task {
                await submitQuiz()
            }
        }
    }

    private func submitQuiz() async {
        guard let userId = authManager.currentUser?.id,
              let ageInt = Int(age),
              let activityLevel = activityLevel,
              let goal = goal,
              let sex = sex else {
            errorMessage = "Missing required information"
            showError = true
            return
        }

        // Convert height and weight based on units preference
        let heightInCm: Int
        let weightInKg: Double

        if unitsPreference == .imperial {
            // Convert from imperial to metric for storage
            guard let heightInches = Double(heightCm),
                  let weightLbs = Double(weightKg) else {
                errorMessage = "Invalid height or weight"
                showError = true
                return
            }
            heightInCm = Int(heightInches * 2.54)
            weightInKg = weightLbs / 2.20462
        } else {
            guard let height = Double(heightCm),
                  let weight = Double(weightKg) else {
                errorMessage = "Invalid height or weight"
                showError = true
                return
            }
            heightInCm = Int(height)
            weightInKg = weight
        }

        // Create the profile input
        let input = UserProfileInput(
            userId: userId,
            unitsPreference: unitsPreference,
            age: ageInt,
            heightCm: heightInCm,
            weightKg: weightInKg,
            workoutsPerWeek: workoutsPerWeek,
            activityLevel: activityLevel,
            dietaryPreferences: dietaryPreferences.isEmpty ? nil : Array(dietaryPreferences),
            allergies: allergies.isEmpty ? nil : Array(allergies),
            goal: goal
        )

        // Calculate target calories
        let targetCalories = input.calculateTargetCalories(sex: sex)

        // Create the encodable struct for Supabase
        struct ProfileCreate: Encodable {
            let userId: UUID
            let unitsPreference: String
            let age: Int
            let heightCm: Int
            let weightKg: Double
            let workoutsPerWeek: Int
            let activityLevel: String
            let dietaryPreferences: [String]?
            let allergies: [String]?
            let goal: String
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

        let profileData = ProfileCreate(
            userId: userId,
            unitsPreference: unitsPreference.rawValue,
            age: ageInt,
            heightCm: heightInCm,
            weightKg: weightInKg,
            workoutsPerWeek: workoutsPerWeek,
            activityLevel: activityLevel.rawValue,
            dietaryPreferences: input.dietaryPreferences,
            allergies: input.allergies,
            goal: goal.rawValue,
            targetCalories: targetCalories,
            onboardingCompleted: true
        )

        // Submit to Supabase
        do {
            let client = SupabaseManager.client

            let _: UserProfile = try await client
                .from("user_profiles")
                .insert(profileData)
                .select()
                .single()
                .execute()
                .value

            // Profile created successfully - AuthManager will handle the state update
            print("✅ Profile created successfully")
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            showError = true
            print("❌ Error creating profile: \(error)")
        }
    }
}

#Preview {
    OnboardingQuizView()
        .environmentObject(AuthManager())
}
