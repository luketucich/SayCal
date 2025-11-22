import SwiftUI
import Charts

struct CaloriesPieChart: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var userManager: UserManager

    var proteinColor: Color = .blue
    var carbsColor: Color = .green
    var fatsColor: Color = .orange
    var remainingCalories: Int = 1847

    @State private var animateProgress: Bool = false

    private var proteinPercent: Double {
        guard let profile = userManager.profile else { return 0.30 }
        return Double(profile.proteinPercent) / 100.0
    }

    private var carbsPercent: Double {
        guard let profile = userManager.profile else { return 0.40 }
        return Double(profile.carbsPercent) / 100.0
    }

    private var fatsPercent: Double {
        guard let profile = userManager.profile else { return 0.30 }
        return Double(profile.fatsPercent) / 100.0
    }

    private var totalCalories: Int {
        userManager.profile?.targetCalories ?? 2400
    }

    private var consumedCalories: Int {
        totalCalories - remainingCalories
    }

    private var progressPercent: Double {
        guard totalCalories > 0 else { return 0 }
        return Double(consumedCalories) / Double(totalCalories)
    }

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Circular progress indicator
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(UIColor.systemGray5), lineWidth: 20)

                // Progress circle
                Circle()
                    .trim(from: 0, to: animateProgress ? progressPercent : 0)
                    .stroke(
                        AppColors.primaryText,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.75), value: animateProgress)

                // Center content
                VStack(spacing: AppSpacing.xs) {
                    Text("\(remainingCalories)")
                        .font(AppTypography.displayLarge)
                        .foregroundColor(AppColors.primaryText)

                    Text("calories left")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)

                    Text("of \(totalCalories)")
                        .font(AppTypography.smallCaption)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            .frame(width: 220, height: 220)

            // Macro breakdown
            HStack(spacing: AppSpacing.sm) {
                MacroIndicator(
                    name: "Protein",
                    percentage: Int(proteinPercent * 100),
                    color: proteinColor
                )

                MacroIndicator(
                    name: "Carbs",
                    percentage: Int(carbsPercent * 100),
                    color: carbsColor
                )

                MacroIndicator(
                    name: "Fats",
                    percentage: Int(fatsPercent * 100),
                    color: fatsColor
                )
            }
        }
        .onAppear {
            animateProgress = true
        }
    }
}

struct MacroIndicator: View {
    let name: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text("\(percentage)%")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.primaryText)

            Text(name)
                .font(AppTypography.smallCaption)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
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
    CaloriesPieChart(
        remainingCalories: 1847
    )
    .environmentObject(UserManager.shared)
    .padding()
}
