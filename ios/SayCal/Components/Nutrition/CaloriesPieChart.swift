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
        VStack(spacing: Spacing.lg) {
            // Circular progress indicator
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.border, lineWidth: LineWidth.chartStroke)

                // Progress circle
                Circle()
                    .trim(from: 0, to: animateProgress ? progressPercent : 0)
                    .stroke(
                        Color.textPrimary,
                        style: StrokeStyle(lineWidth: LineWidth.chartStroke, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(Animation.springBouncy, value: animateProgress)

                // Center content
                VStack(spacing: Spacing.xs) {
                    Text("\(remainingCalories)")
                        .font(.displayLarge)
                        .foregroundColor(.textPrimary)

                    Text("calories left")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text("of \(totalCalories)")
                        .font(.smallCaption)
                        .foregroundColor(.textTertiary)
                }
            }
            .frame(width: Dimensions.pieChartSize, height: Dimensions.pieChartSize)

            // Macro breakdown
            HStack(spacing: Spacing.sm) {
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
        VStack(spacing: Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: Dimensions.iconSmall, height: Dimensions.iconSmall)

            Text("\(percentage)%")
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)

            Text(name)
                .font(.smallCaption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
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
    CaloriesPieChart(
        remainingCalories: 1847
    )
    .environmentObject(UserManager.shared)
    .padding()
}
