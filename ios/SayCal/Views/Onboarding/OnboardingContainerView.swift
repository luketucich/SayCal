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
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    @State private var showSkipConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressBar(currentStep: state.currentStep, totalSteps: state.totalSteps)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                currentStepView
                    .transition(.asymmetric(
                        insertion: .move(edge: state.navigationDirection == .forward ? .trailing : .leading),
                        removal: .move(edge: state.navigationDirection == .forward ? .leading : .trailing)
                    ))
                    .id(state.currentStep)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        showSkipConfirmation = true
                    } label: {
                        Text("Set up later")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .confirmationDialog("Skip onboarding?", isPresented: $showSkipConfirmation, titleVisibility: .visible) {
                Button("Set up later") {
                    Task {
                        do {
                            try await userManager.completeOnboarding(with: state)
                        } catch {
                            print("Failed to skip onboarding: \(error.localizedDescription)")
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can always update your preferences later in settings.")
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

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 6)

                Capsule()
                    .fill(Color.primary)
                    .frame(
                        width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps),
                        height: 6
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Onboarding Navigation Footer
struct OnboardingFooter: View {
    let showBack: Bool
    let nextLabel: String
    let nextIcon: String
    let onBack: () -> Void
    let onNext: () -> Void

    init(
        showBack: Bool = true,
        nextLabel: String = "Next",
        nextIcon: String = "arrow.right",
        onBack: @escaping () -> Void = {},
        onNext: @escaping () -> Void
    ) {
        self.showBack = showBack
        self.nextLabel = nextLabel
        self.nextIcon = nextIcon
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                if showBack {
                    Button {
                        HapticManager.shared.light()
                        onBack()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }

                Spacer()

                Button {
                    HapticManager.shared.medium()
                    onNext()
                } label: {
                    HStack(spacing: 6) {
                        Text(nextLabel)
                        Image(systemName: nextIcon)
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(minWidth: 100)
                    .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 14))
                .tint(.primary)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    OnboardingContainerView()
}
