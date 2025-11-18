import SwiftUI
import Combine

/// Navigation direction for onboarding transitions
enum NavigationDirection {
    case forward
    case backward
}

/// Manages the state for the entire onboarding flow
class OnboardingState: ObservableObject {
    // Current step in the onboarding flow
    @Published var currentStep: Int = 0

    // Navigation direction for animations
    @Published var navigationDirection: NavigationDirection = .forward

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
            navigationDirection = .forward
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }

    /// Returns to the previous onboarding step
    func previousStep() {
        if currentStep > 0 {
            navigationDirection = .backward
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }

    /// Calculates target calories based on current user stats and selected goal.
    /// Uses the centralized calculation function with proper metric conversions.
    var targetCalories: Int {
        // Convert to metric if needed (database stores everything in metric)
        let weightKg: Double
        if unitsPreference == .imperial {
            weightKg = weightLbs.lbsToKg
        } else {
            weightKg = self.weightKg
        }

        let heightCm: Int
        if unitsPreference == .imperial {
            heightCm = feetAndInchesToCm(feet: heightFeet, inches: heightInches)
        } else {
            heightCm = self.heightCm
        }

        // Use centralized calculation function from UserProfileManager
        return UserProfileManager.calculateTargetCalories(
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal
        )
    }
}

/// Main container view for the onboarding flow with Airbnb-style design
struct OnboardingContainerView: View {
    @StateObject private var state = OnboardingState()
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
                        insertion: .move(edge: state.navigationDirection == .forward ? .trailing : .leading),
                        removal: .move(edge: state.navigationDirection == .forward ? .leading : .trailing)
                    ))
                    .id(state.currentStep)
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
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
                    .fill(Color(UIColor.label))
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
