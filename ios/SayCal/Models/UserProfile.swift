import Foundation

// MARK: - User Profile Model
struct UserProfile: Codable {
    let userId: UUID
    let unitsPreference: UnitsPreference
    let age: Int
    let heightCm: Int
    let weightKg: Double
    let workoutsPerWeek: Int
    let activityLevel: ActivityLevel
    let dietaryPreferences: [String]?
    let allergies: [String]?
    let goal: Goal
    let targetCalories: Int
    let createdAt: Date
    let updatedAt: Date
    let onboardingCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case unitsPreference = "units_preference"
        case age
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case workoutsPerWeek = "workouts_per_week"
        case activityLevel = "activity_level"
        case dietaryPreferences = "dietary_preferences"
        case allergies
        case goal
        case targetCalories = "target_calories"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case onboardingCompleted = "onboarding_completed"
    }
}

// MARK: - Enums for constrained fields
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
    
    // Multiplier for TDEE calculation
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
    
    // Calorie adjustment based on goal
    var calorieAdjustment: Int {
        switch self {
        case .loseWeight: return -500  // 500 calorie deficit
        case .maintainWeight: return 0
        case .buildMuscle: return 300   // 300 calorie surplus
        case .gainWeight: return 500    // 500 calorie surplus
        }
    }
}

// MARK: - Common dietary preferences and allergies
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
extension Double {
    var kgToLbs: Double { self * 2.20462 }
    var lbsToKg: Double { self / 2.20462 }
}

extension Int {
    var cmToInches: Int { Int(Double(self) / 2.54) }
    var inchesToCm: Int { Int(Double(self) * 2.54) }
    
    var cmToFeetAndInches: (feet: Int, inches: Int) {
        let totalInches = self.cmToInches
        return (feet: totalInches / 12, inches: totalInches % 12)
    }
}

// Helper function to convert feet and inches to cm
func feetAndInchesToCm(feet: Int, inches: Int) -> Int {
    let totalInches = (feet * 12) + inches
    return totalInches.inchesToCm
}

// MARK: - Profile Creation Helper
struct UserProfileInput {
    let userId: UUID
    let unitsPreference: UnitsPreference
    let age: Int
    let heightCm: Int
    let weightKg: Double
    let workoutsPerWeek: Int
    let activityLevel: ActivityLevel
    let dietaryPreferences: [String]?
    let allergies: [String]?
    let goal: Goal
    
    // Calculate target calories based on user stats
    func calculateTargetCalories(sex: Sex = .male) -> Int {
        // Using Mifflin-St Jeor Equation for BMR
        let bmr: Double
        
        if sex == .male {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * Double(heightCm)) - (5 * Double(age)) - 161
        }
        
        // Calculate TDEE (Total Daily Energy Expenditure)
        let tdee = bmr * activityLevel.activityMultiplier
        
        // Adjust based on goal
        let targetCalories = Int(tdee) + goal.calorieAdjustment
        
        // Ensure minimum safe calories
        let minimumCalories = sex == .male ? 1500 : 1200
        return max(targetCalories, minimumCalories)
    }
}

enum Sex {
    case male
    case female
}
