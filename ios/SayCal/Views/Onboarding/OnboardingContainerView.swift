import SwiftUI
import Combine

/// Manages the state for the entire onboarding flow
class OnboardingState: ObservableObject {
    // Current step in the onboarding flow
    @Published var currentStep: Int = 0

    // User preferences
    @Published var unitsPreference: UnitsPreference = .metric
    @Published var sex: Sex = .male

    // Physical stats
    @Published var age: Int = 25
    @Published var heightCm: Int = 170
    @Published var heightFeet: Int = 5
    @Published var heightInches: Int = 7
    @Published var weightKg: Double = 70.0
    @Published var weightLbs: Double = 154.0

    // Activity and goals
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    @Published var goal: Goal = .maintainWeight

    // Dietary information
    @Published var selectedDietaryPreferences: Set<String> = []
    @Published var selectedAllergies: Set<String> = []

    let totalSteps = 6

    /// Validates whether the user can proceed from the current step
    var canProceed: Bool {
        switch currentStep {
        case 0: // Units preference - always can proceed
            return true
        case 1: // Physical stats - validate age and weight are reasonable
            let ageValid = age >= 13 && age <= 120
            let weightValid = unitsPreference == .metric ?
                (weightKg >= 20 && weightKg <= 500) :
                (weightLbs >= 44 && weightLbs <= 1100)
            return ageValid && weightValid
        case 2: // Activity level - always can proceed
            return true
        case 3: // Goals - always can proceed
            return true
        case 4: // Dietary preferences - optional, can always proceed
            return true
        case 5: // Allergies - optional, can always proceed
            return true
        default:
            return false
        }
    }

    /// Advances to the next onboarding step
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }

    /// Returns to the previous onboarding step
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }

    /// Calculates target calories based on current user stats and selected goal
    var targetCalories: Int {
        // Convert weight to kg if needed
        let weightKg: Double
        if unitsPreference == .imperial {
            weightKg = weightLbs.lbsToKg
        } else {
            weightKg = self.weightKg
        }

        // Convert height to cm if needed
        let heightCm: Int
        if unitsPreference == .imperial {
            heightCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
        } else {
            heightCm = self.heightCm
        }

        // Calculate BMR using Mifflin-St Jeor Equation
        let bmr: Double
        if sex == .male {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) - 161
        }

        // Calculate TDEE (Total Daily Energy Expenditure)
        let tdee = bmr * activityLevel.activityMultiplier

        // Adjust based on selected goal
        let targetCalories = Int(tdee) + goal.calorieAdjustment

        // Ensure minimum safe calories
        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }
}

/// Main container view for the onboarding flow with Airbnb-style design
struct OnboardingContainerView: View {
    @StateObject private var state = OnboardingState()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Clean progress indicator
                ProgressBar(currentStep: state.currentStep, totalSteps: state.totalSteps)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                
                Divider()
                    .overlay(Color(UIColor.systemGray5))
                
                // Content area
                currentStepView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if state.currentStep > 0 {
                        Button {
                            state.previousStep()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(
                                Circle()
                                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch state.currentStep {
        case 0:
            UnitsPreferenceView(state: state)
        case 1:
            PhysicalStatsView(state: state)
        case 2:
            ActivityLevelView(state: state)
        case 3:
            GoalsView(state: state)
        case 4:
            DietaryPreferencesView(state: state)
        case 5:
            AllergiesView(state: state)
        default:
            EmptyView()
        }
    }
}

// Clean progress bar component
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 2)
                
                // Progress fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.black)
                    .frame(
                        width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps),
                        height: 2
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 2)
    }
}

#Preview {
    OnboardingContainerView()
}
