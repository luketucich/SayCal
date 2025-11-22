import SwiftUI

struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    OnboardingHeader(
                        title: "Your goal",
                        subtitle: "What are you trying to achieve?"
                    )

                    VStack(spacing: AppSpacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                Text("Your Target Calories")
                                    .font(AppTypography.caption)
                                    .foregroundColor(AppColors.secondaryText)

                                Text("\(state.targetCalories)")
                                    .font(AppTypography.displayLarge)
                                    .foregroundColor(AppColors.primaryText)

                                Text("calories per day")
                                    .font(AppTypography.smallCaption)
                                    .foregroundColor(AppColors.tertiaryText)
                            }

                            Spacer()
                        }
                        .padding(AppSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .fill(Color(UIColor.systemGray6))
                        )

                        let macros = UserManager.calculateMacroPercentages(for: state.goal)

                        HStack(spacing: AppSpacing.md) {
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
                                .font(AppTypography.smallCaption)
                                .foregroundColor(AppColors.tertiaryText)

                            Text("You can edit your target calories and macros anytime in your profile")
                                .font(AppTypography.smallCaption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }

                    VStack(spacing: AppSpacing.sm) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            SelectableCard(
                                title: goal.displayName,
                                subtitle: goal.calorieAdjustmentText,
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
                .padding(.horizontal, AppSpacing.lg)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(AppColors.lightBackground)
    }
}

struct OnboardingMacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text("\(percentage)%")
                .font(AppTypography.title2)
                .foregroundColor(AppColors.primaryText)

            Text(title)
                .font(AppTypography.smallCaptionMedium)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                        .stroke(Color(UIColor.systemGray5), lineWidth: 1.5)
                )
        )
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
