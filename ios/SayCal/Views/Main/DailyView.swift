import SwiftUI

struct DailyView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var mealLogger = MealLogger.shared
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Date selector
                    DateSelectorView(selectedDate: $selectedDate)
                        .padding(.top, 8)

                    // Nutrition Summary Card
                    NutritionSummaryCard()
                        .environmentObject(userManager)

                    // Meals List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meals")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 4)

                        MealsList(date: selectedDate)
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        HapticManager.shared.medium()
                        mealLogger.resetAllData()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(.secondary)
                    }
                }

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
