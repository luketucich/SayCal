import SwiftUI

struct NutritionSummaryCard: View {
    @EnvironmentObject var userManager: UserManager
    var remainingCalories: Int = 1847

    private var totalCalories: Int {
        userManager.profile?.targetCalories ?? 2400
    }

    private var consumedCalories: Int {
        totalCalories - remainingCalories
    }

    private var progress: Double {
        min(max(Double(consumedCalories) / Double(totalCalories), 0), 1.0)
    }

    private var profile: UserProfile? {
        userManager.profile
    }

    private var carbsConsumed: Int {
        guard let profile = profile else { return 0 }
        let totalCarbs = (totalCalories * profile.carbsPercent) / 400
        let remainingCarbs = (remainingCalories * profile.carbsPercent) / 400
        return totalCarbs - remainingCarbs
    }

    private var carbsTotal: Int {
        guard let profile = profile else { return 0 }
        return (totalCalories * profile.carbsPercent) / 400
    }

    private var fatConsumed: Int {
        guard let profile = profile else { return 0 }
        let totalFat = (totalCalories * profile.fatsPercent) / 900
        let remainingFat = (remainingCalories * profile.fatsPercent) / 900
        return totalFat - remainingFat
    }

    private var fatTotal: Int {
        guard let profile = profile else { return 0 }
        return (totalCalories * profile.fatsPercent) / 900
    }

    private var proteinConsumed: Int {
        guard let profile = profile else { return 0 }
        let totalProtein = (totalCalories * profile.proteinPercent) / 400
        let remainingProtein = (remainingCalories * profile.proteinPercent) / 400
        return totalProtein - remainingProtein
    }

    private var proteinTotal: Int {
        guard let profile = profile else { return 0 }
        return (totalCalories * profile.proteinPercent) / 400
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

                Text("of \(totalCalories)")
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
    NutritionSummaryCard(remainingCalories: 1847)
        .environmentObject(UserManager.shared)
        .padding()
        .background(Color(.systemGroupedBackground))
}
