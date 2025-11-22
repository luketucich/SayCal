import SwiftUI

struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    OnboardingHeader(
                        title: "Your goal",
                        subtitle: "What are you trying to achieve?"
                    )

                    VStack(spacing: Spacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Your Target Calories")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)

                                Text("\(state.targetCalories)")
                                    .font(.displayLarge)
                                    .foregroundColor(.textPrimary)

                                Text("calories per day")
                                    .font(.smallCaption)
                                    .foregroundColor(.textTertiary)
                            }

                            Spacer()
                        }
                        .padding(Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(Color.overlayBackground)
                        )

                        let macros = UserManager.calculateMacroPercentages(for: state.goal)

                        HStack(spacing: Spacing.md) {
                            OnboardingMacroCard(
                                title: "Carbs",
                                percentage: macros.carbs,
                                color: .macroCarbs
                            )

                            OnboardingMacroCard(
                                title: "Fats",
                                percentage: macros.fats,
                                color: .macroFats
                            )

                            OnboardingMacroCard(
                                title: "Protein",
                                percentage: macros.protein,
                                color: .macroProtein
                            )
                        }

                        HStack {
                            Image(systemName: "info.circle")
                                .font(.smallCaption)
                                .foregroundColor(.textTertiary)

                            Text("You can edit your target calories and macros anytime in your profile")
                                .font(.smallCaption)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    VStack(spacing: Spacing.sm) {
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
                .padding(.horizontal, Spacing.lg)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color.appBackground)
    }
}

struct OnboardingMacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: Dimensions.iconXSmall, height: Dimensions.iconXSmall)

            Text("\(percentage)%")
                .font(.title2)
                .foregroundColor(.textPrimary)

            Text(title)
                .font(.smallCaptionMedium)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .stroke(Color.border, lineWidth: LineWidth.regular)
                )
        )
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
