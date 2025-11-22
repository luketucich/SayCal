import SwiftUI

struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sectionSpacing) {
                    OnboardingHeader(
                        title: "Your goal",
                        subtitle: "What are you trying to achieve?"
                    )

                    VStack(spacing: DesignSystem.Spacing.itemSpacing) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Your Target Calories")
                                    .font(DesignSystem.Typography.bodySmall)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)

                                Text("\(state.targetCalories)")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)

                                Text("calories per day")
                                    .font(DesignSystem.Typography.captionLarge)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }

                            Spacer()
                        }
                        .cardPadding()
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                                .fill(DesignSystem.Colors.cardBackground)
                                .lightShadow()
                        )

                        HStack(spacing: DesignSystem.Spacing.itemSpacing) {
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
                                .font(.system(size: DesignSystem.Dimensions.iconSmall))
                                .foregroundColor(DesignSystem.Colors.textTertiary)

                            Text("You can edit your target calories and macros anytime in your profile")
                                .font(DesignSystem.Typography.captionLarge)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }

                    VStack(spacing: DesignSystem.Spacing.itemSpacing) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            SelectableCard(
                                title: goal.displayName,
                                subtitle: goal.calorieAdjustmentText,
                                isSelected: state.goal == goal
                            ) {
                                state.goal = goal
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .screenEdgePadding()
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(DesignSystem.Colors.background)
    }
}

struct OnboardingMacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(DesignSystem.Typography.captionLarge)
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Text("\(percentage)%")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.componentSpacing)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
