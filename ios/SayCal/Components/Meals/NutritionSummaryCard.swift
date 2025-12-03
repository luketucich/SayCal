import SwiftUI

struct NutritionSummaryCard: View {
    @EnvironmentObject var userManager: UserManager
    @ObservedObject var mealLogger = MealManager.shared
    let date: Date

    private var totals: DailyNutritionTotals {
        mealLogger.getTotalsForDate(date)
    }

    private var goalCalories: Int {
        Int(totals.goalCalories)
    }

    private var consumedCalories: Int {
        Int(totals.totalCalories)
    }

    private var remainingCalories: Int {
        Int(totals.remainingCalories)
    }

    private var progress: Double {
        min(max(Double(consumedCalories) / Double(goalCalories), 0), 1.0)
    }

    private var progressBarColor: Color {
        // Interpolate from orange/red (low progress) to green (high progress)
        let hue = progress * 0.33 // 0.0 (red) to 0.33 (green) in HSB color space
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }

    private var carbsConsumed: Int {
        Int(totals.totalCarbs)
    }

    private var fatConsumed: Int {
        Int(totals.totalFats)
    }

    private var proteinConsumed: Int {
        Int(totals.totalProtein)
    }

    var body: some View {
        VStack(spacing: 10) {
            // Calories row
            HStack(alignment: .firstTextBaseline) {
                Text("\(consumedCalories)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text("consumed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("of \(goalCalories)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.1))

                    Capsule()
                        .fill(progressBarColor)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)

            // Macros row
            HStack(spacing: 8) {
                MacroStat(label: "Carbs", consumed: carbsConsumed, color: .orange)

                Text("•")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))

                MacroStat(label: "Fat", consumed: fatConsumed, color: .pink)

                Text("•")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))

                MacroStat(label: "Protein", consumed: proteinConsumed, color: .blue)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }
}

struct MacroStat: View {
    let label: String
    let consumed: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(consumed)g")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(color.opacity(0.8))
        }
    }
}

#Preview {
    NutritionSummaryCard(date: Date())
        .environmentObject(UserManager.shared)
        .padding()
        .background(Color(.systemGroupedBackground))
}
