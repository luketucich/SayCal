import SwiftUI

struct DailyView: View {
    @State private var chart = CaloriesPieChart(
        remainingCalories: 1847,
    )

    var body: some View {
        NavigationStack {
            chart.frame(width: 250, height: 250)
            Spacer()
        }
    }
}

#Preview {
    DailyView()
}
