import SwiftUI

struct DailyView: View {
    @State private var chart = CaloriesPieChart(
        remainingCalories: 1847,
    )

    var body: some View {
        NavigationStack {
            chart.frame(width: 200, height: 200)
            Spacer()
        }
    }
}

#Preview {
    DailyView()
}
