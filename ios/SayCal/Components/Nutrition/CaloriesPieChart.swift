import SwiftUI
import Charts

struct CaloriesPieChart: View {
    @EnvironmentObject var userManager: UserManager
    var remainingCalories: Int = 1847

    private var totalCalories: Int {
        userManager.profile?.targetCalories ?? 2400
    }

    private var consumedCalories: Int {
        totalCalories - remainingCalories
    }

    private var consumedPercent: Double {
        min(Double(consumedCalories) / Double(totalCalories), 1.0)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: 20
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: consumedPercent)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: consumedPercent)

            // Center content
            VStack(spacing: 2) {
                Text("\(remainingCalories)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text("remaining")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("of \(totalCalories)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(8)
    }
}

#Preview {
    CaloriesPieChart(remainingCalories: 1847)
        .environmentObject(UserManager.shared)
        .frame(width: 280, height: 280)
        .padding()
}
