import Foundation
import Combine

// MARK: - Logged Meal Model

struct LoggedMeal: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let transcription: String?
    let nutritionResponse: NutritionResponse

    init(id: String = UUID().uuidString, timestamp: Date = Date(), transcription: String?, nutritionResponse: NutritionResponse) {
        self.id = id
        self.timestamp = timestamp
        self.transcription = transcription
        self.nutritionResponse = nutritionResponse
    }
}

// MARK: - Daily Nutrition Totals

struct DailyNutritionTotals: Codable {
    let date: Date
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFats: Double
    var goalCalories: Double

    var remainingCalories: Double {
        goalCalories - totalCalories
    }

    init(date: Date = Date(), goalCalories: Double = 2000) {
        self.date = date
        self.totalCalories = 0
        self.totalProtein = 0
        self.totalCarbs = 0
        self.totalFats = 0
        self.goalCalories = goalCalories
    }
}

// MARK: - Meal Logger Manager

class MealLogger: ObservableObject {
    static let shared = MealLogger()

    @Published var loggedMeals: [LoggedMeal] = []
    @Published var dailyTotals: DailyNutritionTotals

    private let mealsKey = "logged_meals"
    private let dailyTotalsKey = "daily_nutrition_totals"

    private init() {
        self.dailyTotals = DailyNutritionTotals()
        loadMeals()
        loadDailyTotals()
    }

    // MARK: - Save/Load Meals

    func logMeal(transcription: String?, nutritionResponse: NutritionResponse) {
        let meal = LoggedMeal(transcription: transcription, nutritionResponse: nutritionResponse)
        loggedMeals.append(meal)
        saveMeals()

        // Update daily totals
        if case .success(let analysis) = nutritionResponse {
            updateDailyTotals(adding: analysis)
        }

        print("✅ Meal logged: \(meal.id)")
    }

    func deleteMeal(_ meal: LoggedMeal) {
        loggedMeals.removeAll { $0.id == meal.id }
        saveMeals()

        // Update daily totals
        if case .success(let analysis) = meal.nutritionResponse {
            updateDailyTotals(subtracting: analysis)
        }

        print("🗑️ Meal deleted: \(meal.id)")
    }

    func getMealsForDate(_ date: Date) -> [LoggedMeal] {
        let calendar = Calendar.current
        return loggedMeals.filter { meal in
            calendar.isDate(meal.timestamp, inSameDayAs: date)
        }
    }

    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(loggedMeals) {
            UserDefaults.standard.set(encoded, forKey: mealsKey)
        }
    }

    private func loadMeals() {
        if let data = UserDefaults.standard.data(forKey: mealsKey),
           let decoded = try? JSONDecoder().decode([LoggedMeal].self, from: data) {
            loggedMeals = decoded
        }
    }

    // MARK: - Daily Totals

    private func updateDailyTotals(adding analysis: NutritionAnalysis) {
        checkAndResetDailyTotalsIfNeeded()

        dailyTotals.totalCalories += analysis.totalCalories
        dailyTotals.totalProtein += analysis.totalProtein
        dailyTotals.totalCarbs += analysis.totalCarbs
        dailyTotals.totalFats += analysis.totalFats

        saveDailyTotals()
    }

    private func updateDailyTotals(subtracting analysis: NutritionAnalysis) {
        checkAndResetDailyTotalsIfNeeded()

        dailyTotals.totalCalories = max(0, dailyTotals.totalCalories - analysis.totalCalories)
        dailyTotals.totalProtein = max(0, dailyTotals.totalProtein - analysis.totalProtein)
        dailyTotals.totalCarbs = max(0, dailyTotals.totalCarbs - analysis.totalCarbs)
        dailyTotals.totalFats = max(0, dailyTotals.totalFats - analysis.totalFats)

        saveDailyTotals()
    }

    private func checkAndResetDailyTotalsIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(dailyTotals.date) {
            // New day - reset totals
            dailyTotals = DailyNutritionTotals(goalCalories: dailyTotals.goalCalories)
            saveDailyTotals()
        }
    }

    private func saveDailyTotals() {
        if let encoded = try? JSONEncoder().encode(dailyTotals) {
            UserDefaults.standard.set(encoded, forKey: dailyTotalsKey)
        }
    }

    private func loadDailyTotals() {
        if let data = UserDefaults.standard.data(forKey: dailyTotalsKey),
           let decoded = try? JSONDecoder().decode(DailyNutritionTotals.self, from: data) {
            let calendar = Calendar.current
            if calendar.isDateInToday(decoded.date) {
                dailyTotals = decoded
            } else {
                // Old data - reset for today
                dailyTotals = DailyNutritionTotals(goalCalories: decoded.goalCalories)
            }
        }
    }

    func updateGoalCalories(_ newGoal: Double) {
        dailyTotals.goalCalories = newGoal
        saveDailyTotals()
    }

    // MARK: - Testing/Debug

    func resetAllData() {
        loggedMeals.removeAll()
        dailyTotals = DailyNutritionTotals(goalCalories: dailyTotals.goalCalories)
        saveMeals()
        saveDailyTotals()
        print("🔄 All meal data reset")
    }
}
