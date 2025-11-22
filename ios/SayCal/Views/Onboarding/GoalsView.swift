import SwiftUI

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
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("Your Target Calories")
                                    .font(DesignSystem.Typography.subheadline(weight: .medium))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)

                                Text("\(state.targetCalories)")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: DesignSystem.Colors.primaryGradient,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )

                                Text("calories per day")
                                    .font(DesignSystem.Typography.footnote(weight: .regular))
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }

                            Spacer()
                        }
                        .padding(DesignSystem.Spacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                .fill(
                                    LinearGradient(
                                        colors: DesignSystem.Colors.primaryGradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .opacity(0.1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                        .stroke(
                                            LinearGradient(
                                                colors: DesignSystem.Colors.primaryGradient,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            .opacity(0.3),
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: DesignSystem.Colors.primary.opacity(0.1), radius: 12, x: 0, y: 6)

                        HStack(spacing: 12) {
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
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text("You can edit your target calories and macros anytime in your profile")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                    }

                    VStack(spacing: 12) {
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
                .padding(.horizontal, 20)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct OnboardingMacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.caption1(weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text("\(percentage)%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(color.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
