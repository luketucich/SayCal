import SwiftUI

struct MealsList: View {
    @ObservedObject var mealLogger = MealLogger.shared
    let date: Date

    private var mealsForDate: [LoggedMeal] {
        mealLogger.getMealsForDate(date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if mealsForDate.isEmpty {
                emptyState
            } else {
                ForEach(mealsForDate) { meal in
                    MealCard(meal: meal, onDelete: {
                        mealLogger.deleteMeal(meal)
                    })
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            Text("No meals logged yet")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }
}

struct MealCard: View {
    let meal: LoggedMeal
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    private var analysis: NutritionAnalysis? {
        if case .success(let data) = meal.nutritionResponse {
            return data
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Time and Delete Button
            HStack {
                Text(meal.timestamp, style: .time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    HapticManager.shared.light()
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            if let analysis = analysis {
                // Meal Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.mealType)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text(analysis.description)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                Divider()

                // Nutrition Summary
                HStack(spacing: 16) {
                    // Calories
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Calories")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)

                        Text("\(Int(analysis.totalCalories))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        + Text(" kcal")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Macros
                    HStack(spacing: 10) {
                        miniMacro(label: "P", value: analysis.totalProtein, color: .blue)
                        miniMacro(label: "C", value: analysis.totalCarbs, color: .orange)
                        miniMacro(label: "F", value: analysis.totalFats, color: .purple)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .confirmationDialog("Delete this meal?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                HapticManager.shared.medium()
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func miniMacro(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)

            Text("\(Int(value))g")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(width: 36)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.12))
        )
    }
}

#Preview {
    MealsList(date: Date())
}
