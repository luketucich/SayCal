import SwiftUI

struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xxl) {
                    OnboardingHeader(
                        title: "Your goal",
                        subtitle: "What are you trying to achieve?"
                    )

                    VStack(spacing: DSSpacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text("Your Target Calories")
                                    .font(DSTypography.bodyMedium)
                                    .foregroundColor(Color.textSecondary)

                                Text("\(state.targetCalories)")
                                    .font(DSTypography.displayMedium)
                                    .foregroundColor(Color.textPrimary)

                                Text("calories per day")
                                    .font(DSTypography.bodySmall)
                                    .foregroundColor(Color.textTertiary)
                            }

                            Spacer()
                        }
                        .padding(DSSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .fill(Color.backgroundTertiary)
                        )

                        HStack(spacing: DSSpacing.sm) {
                            let macros = UserManager.calculateMacroPercentages(for: state.goal)

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
                                .font(DSTypography.labelMedium)
                                .foregroundColor(Color.textTertiary)

                            Text("You can edit your target calories and macros anytime in your profile")
                                .font(DSTypography.bodySmall)
                                .foregroundColor(Color.textSecondary)
                        }
                    }

                    VStack(spacing: DSSpacing.sm) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            SelectableCard(
                                title: goal.displayName,
                                subtitle: goal.calorieAdjustmentText,
                                isSelected: state.goal == goal
                            ) {
                                withAnimation(DSAnimation.quick) {
                                    state.goal = goal
                                }
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DSSpacing.lg)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color.backgroundPrimary)
    }
}

struct OnboardingMacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(title)
                .font(DSTypography.labelSmall)
                .foregroundColor(Color.textSecondary)

            Text("\(percentage)%")
                .font(DSTypography.headingLarge)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
