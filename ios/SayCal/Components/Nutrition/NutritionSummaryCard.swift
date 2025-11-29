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
                Text("\(remainingCalories)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text("left")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("of \(goalCalories)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.1))

                    Capsule()
                        .fill(Color.primary)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 5)

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
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.tertiarySystemGroupedBackground)))
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
