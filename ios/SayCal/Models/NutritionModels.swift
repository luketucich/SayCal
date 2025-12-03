import Foundation

// MARK: - Nutrition Response Types

struct Micronutrient: Codable, Identifiable {
    let name: String
    let value: Double
    let unit: String

    var id: String { name }

    var displayText: String {
        "\(name) \(value)\(unit)"
    }
}

struct NutritionItem: Codable, Identifiable {
    let item: String
    let portion: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
    let micros: [Micronutrient]

    var id: String { item + portion }
}

struct NutritionAnalysis: Codable {
    let mealType: String
    let description: String
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFats: Double
    let breakdown: [NutritionItem]
    
    enum CodingKeys: String, CodingKey {
        case mealType = "meal_type"
        case description
        case totalCalories = "total_calories"
        case totalProtein = "total_protein"
        case totalCarbs = "total_carbs"
        case totalFats = "total_fats"
        case breakdown
    }
}

/// Response from the nutrition analysis API
/// All fields are always present (strict JSON schema requirement), but some are null based on success/failure
enum NutritionResponse: Codable {
    case success(NutritionAnalysis)
    case failure(error: String, unparseableMeal: String?)
    
    var analysis: NutritionAnalysis? {
        if case .success(let data) = self { return data }
        return nil
    }
    
    var errorMessage: String? {
        if case .failure(let error, _) = self { return error }
        return nil
    }
    
    // The API always returns all four fields, with nulls for unused ones
    private struct APIResponse: Codable {
        let success: Bool
        let data: NutritionAnalysis?
        let error: String?
        let unparseableMeal: String?
        
        enum CodingKeys: String, CodingKey {
            case success, data, error
            case unparseableMeal = "unparseable_meal"
        }
    }
    
    init(from decoder: Decoder) throws {
        let response = try APIResponse(from: decoder)
        
        if response.success, let data = response.data {
            self = .success(data)
        } else {
            self = .failure(
                error: response.error ?? "Unknown error",
                unparseableMeal: response.unparseableMeal
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .success(let data):
            let response = APIResponse(
                success: true,
                data: data,
                error: nil,
                unparseableMeal: nil
            )
            try container.encode(response)
            
        case .failure(let error, let unparseableMeal):
            let response = APIResponse(
                success: false,
                data: nil,
                error: error,
                unparseableMeal: unparseableMeal
            )
            try container.encode(response)
        }
    }
}

// MARK: - Preview Helpers

extension NutritionAnalysis {
    static let preview = NutritionAnalysis(
        mealType: "Lunch",
        description: "Grilled chicken breast with rice and broccoli",
        totalCalories: 530,
        totalProtein: 45,
        totalCarbs: 50,
        totalFats: 12,
        breakdown: [
            NutritionItem(
                item: "Grilled Chicken Breast",
                portion: "6 oz",
                calories: 280,
                protein: 42,
                carbs: 0,
                fats: 6,
                micros: [
                    Micronutrient(name: "Iron", value: 1.5, unit: "mg"),
                    Micronutrient(name: "Vitamin B12", value: 0.6, unit: "mcg")
                ]
            ),
            NutritionItem(
                item: "White Rice",
                portion: "1 cup cooked",
                calories: 200,
                protein: 4,
                carbs: 45,
                fats: 0.5,
                micros: []
            ),
            NutritionItem(
                item: "Steamed Broccoli",
                portion: "1 cup",
                calories: 50,
                protein: 4,
                carbs: 10,
                fats: 0.5,
                micros: [
                    Micronutrient(name: "Vitamin C", value: 81, unit: "mg"),
                    Micronutrient(name: "Vitamin K", value: 93, unit: "mcg")
                ]
            )
        ]
    )
}
