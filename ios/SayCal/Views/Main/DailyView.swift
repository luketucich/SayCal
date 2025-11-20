import SwiftUI

struct DailyView: View {
    @State private var chart = CaloriesPieChart(
        remainingCalories: 1847
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: DS.Spacing.xLarge) {
                chart
                    .frame(width: 250, height: 250)

                Spacer()
            }
            .padding(DS.Spacing.large)
            .background(DS.Colors.background)
        }
    }
}

#Preview {
    DailyView()
}
