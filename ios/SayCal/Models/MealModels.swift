import Foundation

// MARK: - Meal Models

struct LoggedMeal: Codable, Identifiable {
    let id: String
    let timestamp: Date
    var transcription: String?
    var nutritionResponse: NutritionResponse?
    var isLoading: Bool

    init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        transcription: String?,
        nutritionResponse: NutritionResponse? = nil,
        isLoading: Bool = false
    ) {
        self.id = id
        self.timestamp = timestamp
        self.transcription = transcription
        self.nutritionResponse = nutritionResponse
        self.isLoading = isLoading
    }
}

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
