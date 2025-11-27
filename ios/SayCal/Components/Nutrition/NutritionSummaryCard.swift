import SwiftUI

struct NutritionSummaryCard: View {
    @EnvironmentObject var userManager: UserManager
    @ObservedObject var mealLogger = MealLogger.shared

    private var goalCalories: Int {
        Int(mealLogger.dailyTotals.goalCalories)
    }

    private var consumedCalories: Int {
        Int(mealLogger.dailyTotals.totalCalories)
    }

    private var remainingCalories: Int {
        Int(mealLogger.dailyTotals.remainingCalories)
    }

    private var progress: Double {
        min(max(Double(consumedCalories) / Double(goalCalories), 0), 1.0)
    }

    private var carbsConsumed: Int {
        Int(mealLogger.dailyTotals.totalCarbs)
    }

    private var fatConsumed: Int {
        Int(mealLogger.dailyTotals.totalFats)
    }

    private var proteinConsumed: Int {
        Int(mealLogger.dailyTotals.totalProtein)
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
                MacroStat(label: "Carbs", consumed: carbsConsumed)

                Text("•")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))

                MacroStat(label: "Fat", consumed: fatConsumed)

                Text("•")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12))

                MacroStat(label: "Protein", consumed: proteinConsumed)
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

    var body: some View {
        VStack(spacing: 2) {
            Text("\(consumed)g")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NutritionSummaryCard()
        .environmentObject(UserManager.shared)
        .padding()
        .background(Color(.systemGroupedBackground))
}
