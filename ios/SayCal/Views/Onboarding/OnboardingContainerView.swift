import SwiftUI
import Combine

class OnboardingState: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var unitsPreference: UnitsPreference = .metric
    @Published var sex: Sex = .male
    @Published var age: String = ""
    @Published var heightCm: Int = 170
    @Published var heightFeet: Int = 5
    @Published var heightInches: Int = 7
    @Published var weightKg: String = ""
    @Published var weightLbs: String = ""
    @Published var workoutsPerWeek: Int = 3
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    @Published var goal: Goal = .maintainWeight
    @Published var selectedDietaryPreferences: Set<String> = []
    @Published var selectedAllergies: Set<String> = []

    let totalSteps = 6

    var canProceed: Bool {
        switch currentStep {
        case 0: // Units preference - always can proceed
            return true
        case 1: // Physical stats
            let ageValid = !age.isEmpty && Int(age) != nil && Int(age)! > 0
            let weightValid = unitsPreference == .metric ?
                (!weightKg.isEmpty && Double(weightKg) != nil && Double(weightKg)! > 0) :
                (!weightLbs.isEmpty && Double(weightLbs) != nil && Double(weightLbs)! > 0)
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

    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
}

struct OnboardingContainerView: View {
    @StateObject private var state = OnboardingState()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 0.15, green: 0.1, blue: 0.3),
                    Color(red: 0.25, green: 0.15, blue: 0.35),
                    Color(red: 0.1, green: 0.2, blue: 0.3)
                ] : [
                    Color(red: 0.9, green: 0.7, blue: 0.95),
                    Color(red: 0.7, green: 0.85, blue: 1.0),
                    Color(red: 0.95, green: 0.8, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<state.totalSteps, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= state.currentStep ? Color.accentColor : Color.primary.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Content area with sheet background
                VStack(spacing: 0) {
                    currentStepView
                }
                .background(Color(.systemBackground))
                .cornerRadius(32)
                .padding(.top, 8)
            }.ignoresSafeArea(edges: .bottom)
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

#Preview {
    OnboardingContainerView()
}
