import SwiftUI

struct MealsList: View {
    @ObservedObject var mealLogger = MealManager.shared
    let date: Date
    let onMealTap: (LoggedMeal) -> Void

    private var mealsForDate: [LoggedMeal] {
        mealLogger.getMealsForDate(date)
    }

    private var loadingMeals: [LoggedMeal] {
        mealsForDate.filter { $0.isLoading }.sorted { $0.timestamp > $1.timestamp }
    }

    private var completedMeals: [LoggedMeal] {
        mealsForDate.filter { !$0.isLoading }
    }

    private var groupedMeals: [(MealType, [LoggedMeal])] {
        let groups = Dictionary(grouping: completedMeals) { meal -> MealType in
            if let response = meal.nutritionResponse,
               case .success(let analysis) = response {
                return MealType(rawValue: analysis.mealType) ?? .snack
            }
            return .snack
        }

        return MealType.allCases.compactMap { type in
            guard let meals = groups[type], !meals.isEmpty else { return nil }
            return (type, meals.sorted { $0.timestamp < $1.timestamp })
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if mealsForDate.isEmpty {
                emptyState
            } else {
                // Loading meals (no category)
                ForEach(loadingMeals) { meal in
                    MealCard(
                        meal: meal,
                        onDelete: {
                            mealLogger.deleteMeal(meal)
                        },
                        onTap: {
                            onMealTap(meal)
                        }
                    )
                }

                // Completed meals (with categories)
                ForEach(groupedMeals, id: \.0) { mealType, meals in
                    VStack(alignment: .leading, spacing: 8) {
                        MealCategoryHeader(mealType: mealType)

                        ForEach(meals) { meal in
                            MealCard(
                                meal: meal,
                                onDelete: {
                                    mealLogger.deleteMeal(meal)
                                },
                                onTap: {
                                    onMealTap(meal)
                                }
                            )
                        }
                    }
                }
            }
        }.padding(.horizontal, 20)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.system(size: 40, weight: .light, design: .rounded))
                .foregroundStyle(.tertiary)

            Text("No meals logged yet")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

            Text("Tap the + button to add your first meal")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }
}

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case drink = "Drink"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        case .drink: return "drop.fill"
        }
    }
}

struct MealCategoryHeader: View {
    let mealType: MealType

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mealType.icon)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(mealType.rawValue)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .padding(.leading, 4)
    }
}

struct MealCard: View {
    let meal: LoggedMeal
    let onDelete: () -> Void
    let onTap: () -> Void

    private var analysis: NutritionAnalysis? {
        if let response = meal.nutritionResponse, case .success(let data) = response {
            return data
        }
        return nil
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if meal.isLoading {
                Text(meal.timestamp, style: .time)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text("•")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 2)

                // Show AI-generated title if available, otherwise shimmer
                if let aiTitle = meal.aiGeneratedTitle {
                    Text(aiTitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .lineLimit(3)
                } else {
                    ShimmerView(width: 140, height: 12)
                        .frame(maxWidth: .infinity)
                        .lineLimit(3)
                }

                Text("•")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 2)

                ShimmerView(width: 50, height: 14)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
            } else if let analysis = analysis {
                Text(meal.timestamp, style: .time)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text("•")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 2)

                // Prioritize AI-generated title, fall back to API description
                Text(meal.aiGeneratedTitle ?? analysis.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .lineLimit(3)

                Text("•")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 2)

                Text("\(Int(analysis.totalCalories))")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                + Text(" cal")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
        .contentShape(Rectangle())
        .onTapGesture {
            if !meal.isLoading {
                HapticManager.shared.light()
                onTap()
            }
        }
    }
}

#Preview {
    MealsList(date: Date(), onMealTap: { _ in })
}
