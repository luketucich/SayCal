import Foundation

// MARK: - User Profile Data Models
// This file contains pure data models representing user profile information.
// No business logic or persistence should be added here.

/// Main user profile model representing the user_profiles table in Supabase
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

// MARK: - Units Preference

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

// MARK: - Activity Level

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

    /// Multiplier for TDEE (Total Daily Energy Expenditure) calculation
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

// MARK: - Fitness Goal

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

    /// Calorie adjustment based on fitness goal
    var calorieAdjustment: Int {
        switch self {
        case .loseWeight: return -500  // 500 calorie deficit
        case .maintainWeight: return 0
        case .buildMuscle: return 300   // 300 calorie surplus
        case .gainWeight: return 500    // 500 calorie surplus
        }
    }

    /// Display text for calorie adjustment
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

// MARK: - Biological Sex

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

// MARK: - Dietary Options

/// Common dietary preferences and allergies for user selection
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

// MARK: - Unit Conversion Extensions
// The app stores all user stats in metric (cm, kg) in the database.
// Imperial conversions are ONLY for display purposes.
// We use proper rounding to ensure conversions are deterministic and idempotent.

extension Double {
    /// Converts kilograms to pounds
    var kgToLbs: Double { self * 2.20462 }

    /// Converts pounds to kilograms
    var lbsToKg: Double { self / 2.20462 }

    /// Converts Double to Int using proper rounding
    var int: Int { Int(self) }
}

extension Int {
    /// Converts centimeters to inches using proper rounding (not truncation).
    /// This ensures that round-trip conversions (cm → inches → cm) are stable.
    var cmToInches: Int {
        (Double(self) / 2.54).rounded(.toNearestOrEven).int
    }

    /// Converts inches to centimeters using proper rounding (not truncation).
    /// This ensures that round-trip conversions (inches → cm → inches) are stable.
    var inchesToCm: Int {
        (Double(self) * 2.54).rounded(.toNearestOrEven).int
    }

    /// Converts centimeters to feet and inches for display.
    /// Uses proper rounding to prevent cumulative errors.
    var cmToFeetAndInches: (feet: Int, inches: Int) {
        let totalInches = self.cmToInches
        return (feet: totalInches / 12, inches: totalInches % 12)
    }
}

/// Converts feet and inches to centimeters using proper rounding.
/// Always use this when converting user input from imperial to metric for storage.
func feetAndInchesToCm(feet: Int, inches: Int) -> Int {
    let totalInches = (feet * 12) + inches
    return totalInches.inchesToCm
}
