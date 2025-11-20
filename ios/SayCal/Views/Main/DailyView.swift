import SwiftUI

struct DailyView: View {
    @State private var chart = CaloriesPieChart(
        remainingCalories: 1847,
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
