import Foundation
import Combine
import Supabase

// MARK: - Meal Manager

/// Manages meal logging and nutrition tracking
///
/// **Meal Logging Flow:**
/// 1. User inputs meal via voice (AudioRecordingOverlay) or text (MealInputToolbar)
/// 2. Voice input → WhisperKit (LocalTranscriptionManager) → transcription
/// 3. createLoadingMeal() creates placeholder with transcription
/// 4. analyzeMealInBackground() sends request via BackgroundNetworkManager
/// 5. Background task continues even if app is closed/suspended
/// 6. BackgroundNetworkManager calls updateMeal() when complete
/// 7. UI automatically updates via @Published properties
class MealManager: ObservableObject {
    static let shared = MealManager()

    @Published var loggedMeals: [LoggedMeal] = []
    @Published var dailyTotals: DailyNutritionTotals

    private let mealsKey = "logged_meals"
    private let dailyTotalsKey = "daily_nutrition_totals"

    private init() {
        let goalCalories = UserManager.shared.profile?.targetCalories ?? 2000
        self.dailyTotals = DailyNutritionTotals(goalCalories: Double(goalCalories))
        loadMeals()
        loadDailyTotals()
        cleanupStaleLoadingMeals()
    }

    private func cleanupStaleLoadingMeals() {
        let staleCount = loggedMeals.filter { $0.isLoading }.count
        guard staleCount > 0 else { return }

        loggedMeals.removeAll { $0.isLoading }
        saveMeals()
        print("🧹 Removed \(staleCount) stale loading meal(s)")
    }

    // MARK: - Meal Management

    func createLoadingMeal(transcription: String?) -> String {
        let meal = LoggedMeal(
            transcription: transcription,
            aiGeneratedTitle: nil,
            nutritionResponse: nil,
            isLoading: true
        )
        loggedMeals.append(meal)
        saveMeals()

        // Generate AI title using Foundation Models (iOS 26.0+)
        if let transcription = transcription {
            Task {
                if #available(iOS 26.0, *) {
                    if let title = await AIHelpers.generateMealTitle(from: transcription) {
                        await MainActor.run {
                            if let index = loggedMeals.firstIndex(where: { $0.id == meal.id }) {
                                loggedMeals[index].aiGeneratedTitle = title
                                saveMeals()
                            }
                        }
                    }
                }
            }
        }

        return meal.id
    }

    func updateMeal(id: String, nutritionResponse: NutritionResponse) {
        guard let index = loggedMeals.firstIndex(where: { $0.id == id }) else { return }

        loggedMeals[index].nutritionResponse = nutritionResponse
        loggedMeals[index].isLoading = false
        saveMeals()

        if case .success(let analysis) = nutritionResponse {
            updateDailyTotals(adding: analysis)
        }
    }

    func deleteMeal(_ meal: LoggedMeal) {
        loggedMeals.removeAll { $0.id == meal.id }
        saveMeals()

        if let response = meal.nutritionResponse, case .success(let analysis) = response {
            updateDailyTotals(subtracting: analysis)
        }
    }

    func getMealsForDate(_ date: Date) -> [LoggedMeal] {
        loggedMeals.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }

    func getTotalsForDate(_ date: Date) -> DailyNutritionTotals {
        let goalCalories = UserManager.shared.profile?.targetCalories ?? 2000
        var totals = DailyNutritionTotals(date: date, goalCalories: Double(goalCalories))

        for meal in getMealsForDate(date) {
            if let response = meal.nutritionResponse, case .success(let analysis) = response {
                totals.totalCalories += analysis.totalCalories
                totals.totalProtein += analysis.totalProtein
                totals.totalCarbs += analysis.totalCarbs
                totals.totalFats += analysis.totalFats
            }
        }

        return totals
    }

    // MARK: - Nutrition Analysis (Background)

    func analyzeMealInBackground(mealId: String, transcription: String) async {
        guard let userId = try? await SupabaseManager.client.auth.session.user.id else {
            print("❌ No authenticated user for background analysis")
            // Remove the loading meal if we can't get user ID
            if let meal = loggedMeals.first(where: { $0.id == mealId }) {
                deleteMeal(meal)
            }
            return
        }

        print("🌐 Starting background analysis for meal: \(mealId)")

        do {
            try await BackgroundNetworkManager.shared.analyzeMeal(
                mealId: mealId,
                transcription: transcription,
                userId: userId.uuidString
            )
        } catch {
            print("❌ Failed to start background analysis: \(error)")
            // Remove the loading meal if background task fails to start
            if let meal = loggedMeals.first(where: { $0.id == mealId }) {
                deleteMeal(meal)
            }
        }
    }

    // MARK: - Persistence

    func saveMeals() {
        if let encoded = try? JSONEncoder().encode(loggedMeals) {
            UserDefaults.standard.set(encoded, forKey: mealsKey)
        }
    }

    private func loadMeals() {
        guard let data = UserDefaults.standard.data(forKey: mealsKey),
              let decoded = try? JSONDecoder().decode([LoggedMeal].self, from: data) else { return }
        loggedMeals = decoded
    }

    // MARK: - Daily Totals

    private func updateDailyTotals(adding analysis: NutritionAnalysis) {
        ensureTotalsAreForToday()
        dailyTotals.totalCalories += analysis.totalCalories
        dailyTotals.totalProtein += analysis.totalProtein
        dailyTotals.totalCarbs += analysis.totalCarbs
        dailyTotals.totalFats += analysis.totalFats
        saveDailyTotals()
    }

    private func updateDailyTotals(subtracting analysis: NutritionAnalysis) {
        ensureTotalsAreForToday()
        dailyTotals.totalCalories = max(0, dailyTotals.totalCalories - analysis.totalCalories)
        dailyTotals.totalProtein = max(0, dailyTotals.totalProtein - analysis.totalProtein)
        dailyTotals.totalCarbs = max(0, dailyTotals.totalCarbs - analysis.totalCarbs)
        dailyTotals.totalFats = max(0, dailyTotals.totalFats - analysis.totalFats)
        saveDailyTotals()
    }

    private func ensureTotalsAreForToday() {
        guard !Calendar.current.isDateInToday(dailyTotals.date) else { return }
        let goalCalories = UserManager.shared.profile?.targetCalories ?? 2000
        dailyTotals = DailyNutritionTotals(goalCalories: Double(goalCalories))
        saveDailyTotals()
    }

    func syncGoalCaloriesFromProfile() {
        let goalCalories = UserManager.shared.profile?.targetCalories ?? 2000
        dailyTotals.goalCalories = Double(goalCalories)
        saveDailyTotals()
    }

    private func saveDailyTotals() {
        guard let encoded = try? JSONEncoder().encode(dailyTotals) else { return }
        UserDefaults.standard.set(encoded, forKey: dailyTotalsKey)
    }

    private func loadDailyTotals() {
        guard let data = UserDefaults.standard.data(forKey: dailyTotalsKey),
              let decoded = try? JSONDecoder().decode(DailyNutritionTotals.self, from: data) else { return }

        let goalCalories = UserManager.shared.profile?.targetCalories ?? 2000

        if Calendar.current.isDateInToday(decoded.date) {
            dailyTotals = decoded
            dailyTotals.goalCalories = Double(goalCalories)
        } else {
            dailyTotals = DailyNutritionTotals(goalCalories: Double(goalCalories))
        }
    }

    // MARK: - Debug

    func resetAllData() {
        loggedMeals.removeAll()
        dailyTotals = DailyNutritionTotals(goalCalories: dailyTotals.goalCalories)
        saveMeals()
        saveDailyTotals()
    }
}
