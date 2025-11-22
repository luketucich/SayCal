import SwiftUI
import Combine

enum NavigationDirection {
    case forward
    case backward
}

class OnboardingState: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var navigationDirection: NavigationDirection = .forward
    @Published var unitsPreference: UnitsPreference = .metric
    @Published var sex: Sex = .male
    @Published var age: Int = 25
    @Published var heightCm: Int = 170
    @Published var heightFeet: Int = 5
    @Published var heightInches: Int = 7
    @Published var weightKg: Double = 70.0
    @Published var weightLbs: Double = 154.0
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    @Published var goal: Goal = .maintainWeight
    @Published var selectedDietaryPreferences: Set<String> = []
    @Published var selectedAllergies: Set<String> = []

    let totalSteps = 6
    var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            let ageValid = age >= 13 && age <= 120
            let weightValid = unitsPreference == .metric ?
                (weightKg >= 20 && weightKg <= 500) :
                (weightLbs >= 44 && weightLbs <= 1100)
            return ageValid && weightValid
        case 2, 3, 4, 5:
            return true
        default:
            return false
        }
    }
    func nextStep() {
        if currentStep < totalSteps - 1 {
            navigationDirection = .forward
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        }
    }
    func previousStep() {
        if currentStep > 0 {
            navigationDirection = .backward
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep -= 1
            }
        }
    }
    var targetCalories: Int {
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

        return UserManager.calculateTargetCalories(
            sex: sex,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal
        )
    }
}

struct OnboardingContainerView: View {
    @StateObject private var state = OnboardingState()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressBar(currentStep: state.currentStep, totalSteps: state.totalSteps)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                
                Divider()
                    .overlay(Color(UIColor.systemGray5))

                currentStepView
                    .transition(.asymmetric(
                        insertion: .move(edge: state.navigationDirection == .forward ? .trailing : .leading),
                        removal: .move(edge: state.navigationDirection == .forward ? .leading : .trailing)
                    ))
                    .id(state.currentStep)
            }
            .background(AppColors.lightBackground)
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

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 6)

                // Progress fill
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(UIColor.label))
                    .frame(
                        width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps),
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    OnboardingContainerView()
}
