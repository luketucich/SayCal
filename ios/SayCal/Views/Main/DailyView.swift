import SwiftUI

struct DailyView: View {
    @State private var chart = CaloriesPieChart(
        proteinPercent: 0.30,
        carbsPercent: 0.40,
        fatsPercent: 0.30,
        remainingCalories: 1847,
        totalCalories: 2400
    )

    var body: some View {
        NavigationStack {
            VStack {
                DailyStreakTracker()
                    .padding()

                Spacer()

                chart.frame(width: 200, height: 200)
                    .padding(.bottom, 450)
            }
        }
    }
}

#Preview {
    DailyView()
}
