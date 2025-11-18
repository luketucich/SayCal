import Foundation

// User profile model for the user_profiles table
struct UserProfile: Codable {
    let userId: UUID
    let unitsPreference: UnitsPreference
    let sex: Sex
    let age: Int
    let heightCm: Int
    let weightKg: Double
    let activityLevel: ActivityLevel
    let dietaryPreferences: [String]?
    let allergies: [String]?
    let goal: Goal
    let targetCalories: Int
    let carbsPercent: Int
    let fatsPercent: Int
    let proteinPercent: Int
    let createdAt: Date?
    let updatedAt: Date?
    let onboardingCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case unitsPreference = "units_preference"
        case sex
        case age
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case activityLevel = "activity_level"
        case dietaryPreferences = "dietary_preferences"
        case allergies
        case goal
        case targetCalories = "target_calories"
        case carbsPercent = "carbs_percent"
        case fatsPercent = "fats_percent"
        case proteinPercent = "protein_percent"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case onboardingCompleted = "onboarding_completed"
    }
}

enum UnitsPreference: String, Codable, CaseIterable {
    case metric = "metric"
    case imperial = "imperial"

    var displayName: String {
        switch self {
        case .metric: return "Metric (kg, cm)"
        case .imperial: return "Imperial (lbs, ft/in)"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extremelyActive = "extremely_active"

    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary (little or no exercise)"
        case .lightlyActive: return "Lightly Active (1-3 days/week)"
        case .moderatelyActive: return "Moderately Active (3-5 days/week)"
        case .veryActive: return "Very Active (6-7 days/week)"
        case .extremelyActive: return "Extremely Active (physical job & daily exercise)"
        }
    }

    var activityMultiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
}

enum Goal: String, Codable, CaseIterable {
    case loseWeight = "lose_weight"
    case maintainWeight = "maintain_weight"
    case buildMuscle = "build_muscle"
    case gainWeight = "gain_weight"

    var displayName: String {
        switch self {
        case .loseWeight: return "Lose Weight"
        case .maintainWeight: return "Maintain Weight"
        case .buildMuscle: return "Build Muscle"
        case .gainWeight: return "Gain Weight"
        }
    }

    var calorieAdjustment: Int {
        switch self {
        case .loseWeight: return -500  // 500 calorie deficit
        case .maintainWeight: return 0
        case .buildMuscle: return 300   // 300 calorie surplus
        case .gainWeight: return 500    // 500 calorie surplus
        }
    }

    var calorieAdjustmentText: String {
        let adjustment = calorieAdjustment
        if adjustment > 0 {
            return "+\(adjustment) calories"
        } else if adjustment < 0 {
            return "\(adjustment) calories"
        } else {
            return "Maintain current weight"
        }
    }
}

enum Sex: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"

    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

struct DietaryOptions {
    static let dietaryPreferences = [
        "vegetarian",
        "vegan",
        "pescatarian",
        "keto",
        "paleo",
        "gluten_free",
        "dairy_free",
        "mediterranean",
        "animal_based",
        "carnivore"
    ]

    static let commonAllergies = [
        "peanuts",
        "tree_nuts",
        "milk",
        "eggs",
        "wheat",
        "soy",
        "fish",
        "shellfish",
        "sesame"
    ]
}

extension Double {
    var kgToLbs: Double { self * 2.20462 }
    var lbsToKg: Double { self / 2.20462 }
    var int: Int { Int(self) }
}

extension Int {
    var cmToInches: Int {
        (Double(self) / 2.54).rounded(.toNearestOrEven).int
    }

    var inchesToCm: Int {
        (Double(self) * 2.54).rounded(.toNearestOrEven).int
    }

    var cmToFeetAndInches: (feet: Int, inches: Int) {
        let totalInches = self.cmToInches
        return (feet: totalInches / 12, inches: totalInches % 12)
    }
}

func feetAndInchesToCm(feet: Int, inches: Int) -> Int {
    let totalInches = (feet * 12) + inches
    return totalInches.inchesToCm
}
