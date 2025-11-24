import SwiftUI

struct MacroBreakdownView: View {
    @EnvironmentObject var userManager: UserManager
    var remainingCalories: Int

    private var profile: UserProfile? {
        userManager.profile
    }

    private var carbsGrams: Int {
        guard let profile = profile else { return 0 }
        return (remainingCalories * profile.carbsPercent) / 400
    }

    private var fatGrams: Int {
        guard let profile = profile else { return 0 }
        return (remainingCalories * profile.fatsPercent) / 900
    }

    private var proteinGrams: Int {
        guard let profile = profile else { return 0 }
        return (remainingCalories * profile.proteinPercent) / 400
    }

    var body: some View {
        HStack(spacing: 12) {
            MacroItem(
                name: "Carbs",
                grams: carbsGrams,
                color: .blue
            )

            MacroItem(
                name: "Fat",
                grams: fatGrams,
                color: .orange
            )

            MacroItem(
                name: "Protein",
                grams: proteinGrams,
                color: .green
            )
        }
        .padding(.horizontal, 20)
    }
}

struct MacroItem: View {
    let name: String
    let grams: Int
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("\(grams)g")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())

            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    MacroBreakdownView(remainingCalories: 1847)
        .environmentObject(UserManager.shared)
        .padding()
}
