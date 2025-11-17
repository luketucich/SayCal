import SwiftUI

// Onboarding step 4: Pick your fitness goal (affects calorie target)
struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    OnboardingHeader(
                        title: "Your goal",
                        subtitle: "What are you trying to achieve?"
                    )

                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Target Calories")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(UIColor.secondaryLabel))

                                Text("\(state.targetCalories)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(UIColor.label))

                                Text("calories per day")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                            }

                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray6))
                        )

                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text("You can edit your target calories anytime in your profile")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }

                    VStack(spacing: 12) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            SelectableCard(
                                title: goal.displayName,
                                subtitle: calorieAdjustmentText(for: goal),
                                isSelected: state.goal == goal
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    state.goal = goal
                                }
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
    }

    // Shows how many calories to add/subtract based on the goal
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
