import SwiftUI

struct DailyView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var remainingCalories = 1847
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Date selector
                    DateSelectorView()
                        .padding(.top, 8)

                    // Nutrition Summary Card
                    NutritionSummaryCard(remainingCalories: remainingCalories)
                        .environmentObject(userManager)

                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    DailyView(showSettings: .constant(false))
        .environmentObject(UserManager.shared)
}
