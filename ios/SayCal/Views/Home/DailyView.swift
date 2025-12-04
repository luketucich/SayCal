import SwiftUI

struct DailyView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var mealLogger = MealManager.shared
    @Binding var selectedDate: Date
    let onMealTap: (LoggedMeal) -> Void

    var body: some View {
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

                Spacer(minLength: 100)
            }
        }
        .background(Color.appBackground)
        .onChange(of: userManager.profile?.targetCalories) { _, _ in
            mealLogger.syncGoalCaloriesFromProfile()
        }
    }
}

#Preview {
    DailyView(selectedDate: .constant(Date()), onMealTap: { _ in })
        .environmentObject(UserManager.shared)
}
