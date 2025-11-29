import SwiftUI

struct DailyView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var mealLogger = MealManager.shared
    @Binding var showSettings: Bool
    @Binding var selectedDate: Date
    let onMealTap: (LoggedMeal) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // Date selector
                    DateSelectorView(selectedDate: $selectedDate)
                        .padding(.top, 8)

                    // Nutrition Summary Card
                    NutritionSummaryCard(date: selectedDate)
                        .environmentObject(userManager)

                    // Meals List
                    MealsList(date: selectedDate, onMealTap: onMealTap)

                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: userManager.profile?.targetCalories) { _, _ in
                mealLogger.syncGoalCaloriesFromProfile()
            }
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
    DailyView(showSettings: .constant(false), selectedDate: .constant(Date()), onMealTap: { _ in })
        .environmentObject(UserManager.shared)
}
