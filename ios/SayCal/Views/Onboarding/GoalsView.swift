import SwiftUI

// Onboarding step 4: Pick a fitness goal
// This adjusts daily calorie targets (+ for gain, - for loss)
struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header section
                    OnboardingHeader(
                        title: "Your goal",
                        subtitle: "What are you trying to achieve?"
                    )

                    // Target Calories Display
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

                        // Macro Split Display
                        HStack(spacing: 12) {
                            let macros = UserProfile.calculateMacroPercentages(for: state.goal)

                            OnboardingMacroCard(
                                title: "Carbs",
                                percentage: macros.carbs,
                                color: .blue
                            )

                            OnboardingMacroCard(
                                title: "Fats",
                                percentage: macros.fats,
                                color: .orange
                            )

                            OnboardingMacroCard(
                                title: "Protein",
                                percentage: macros.protein,
                                color: .green
                            )
                        }

                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text("You can edit your target calories and macros anytime in your profile")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }

                    // Goal selection
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

            // Bottom button area
            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
    }

    // Formats calorie adjustment (+500, -300, etc.)
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

// MARK: - Onboarding Macro Card Component
struct OnboardingMacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(UIColor.secondaryLabel))

            Text("\(percentage)%")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
