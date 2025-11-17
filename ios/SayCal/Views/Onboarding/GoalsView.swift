import SwiftUI

/// Step 4: Collects user's fitness goal
/// Goal determines calorie adjustment (surplus or deficit)
struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your goal")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("What are you trying to achieve?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    ForEach(Goal.allCases, id: \.self) { goal in
                        SelectableCard(
                            title: goal.displayName,
                            subtitle: calorieAdjustmentText(for: goal),
                            isSelected: state.goal == goal
                        ) {
                            state.goal = goal
                        }
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Continue",
                        isEnabled: state.canProceed
                    ) {
                        state.nextStep()
                    }

                    Button {
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(24)
        }
    }

    /// Formats the calorie adjustment for display in the UI
    private func calorieAdjustmentText(for goal: Goal) -> String {
        let adjustment = goal.calorieAdjustment
        if adjustment > 0 {
            return "+\(adjustment) calories"
        } else if adjustment < 0 {
            return "\(adjustment) calories"
        } else {
            return "Maintain current weight"
        }
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
