import SwiftUI

struct MicronutrientTarget {
    let name: String
    let unit: String
    let dailyValue: Double
    let category: String
    let displayOrder: Int
}

struct MicronutrientsSheet: View {
    @ObservedObject var mealLogger = MealManager.shared
    @Environment(\.dismiss) private var dismiss
    let date: Date

    // Daily values based on FDA guidelines and RDA
    private let micronutrientTargets: [MicronutrientTarget] = [
        // Macronutrient Components
        MicronutrientTarget(name: "Fiber", unit: "g", dailyValue: 28, category: "Fiber & Fats", displayOrder: 1),
        MicronutrientTarget(name: "Sugar", unit: "g", dailyValue: 50, category: "Fiber & Fats", displayOrder: 2),
        MicronutrientTarget(name: "Saturated Fat", unit: "g", dailyValue: 20, category: "Fiber & Fats", displayOrder: 3),
        MicronutrientTarget(name: "Cholesterol", unit: "mg", dailyValue: 300, category: "Fiber & Fats", displayOrder: 4),

        // Major Minerals
        MicronutrientTarget(name: "Sodium", unit: "mg", dailyValue: 2300, category: "Minerals", displayOrder: 5),
        MicronutrientTarget(name: "Calcium", unit: "mg", dailyValue: 1000, category: "Minerals", displayOrder: 6),
        MicronutrientTarget(name: "Iron", unit: "mg", dailyValue: 18, category: "Minerals", displayOrder: 7),
        MicronutrientTarget(name: "Potassium", unit: "mg", dailyValue: 3500, category: "Minerals", displayOrder: 8),
        MicronutrientTarget(name: "Magnesium", unit: "mg", dailyValue: 400, category: "Minerals", displayOrder: 9),
        MicronutrientTarget(name: "Phosphorus", unit: "mg", dailyValue: 700, category: "Minerals", displayOrder: 10),
        MicronutrientTarget(name: "Zinc", unit: "mg", dailyValue: 11, category: "Minerals", displayOrder: 11),
        MicronutrientTarget(name: "Selenium", unit: "mcg", dailyValue: 55, category: "Minerals", displayOrder: 12),

        // Vitamins
        MicronutrientTarget(name: "Vitamin A", unit: "mcg", dailyValue: 900, category: "Vitamins", displayOrder: 13),
        MicronutrientTarget(name: "Vitamin C", unit: "mg", dailyValue: 90, category: "Vitamins", displayOrder: 14),
        MicronutrientTarget(name: "Vitamin D", unit: "mcg", dailyValue: 20, category: "Vitamins", displayOrder: 15),
        MicronutrientTarget(name: "Vitamin E", unit: "mg", dailyValue: 15, category: "Vitamins", displayOrder: 16),
        MicronutrientTarget(name: "Vitamin K", unit: "mcg", dailyValue: 120, category: "Vitamins", displayOrder: 17),
        MicronutrientTarget(name: "Vitamin B6", unit: "mg", dailyValue: 1.7, category: "Vitamins", displayOrder: 18),
        MicronutrientTarget(name: "Vitamin B12", unit: "mcg", dailyValue: 2.4, category: "Vitamins", displayOrder: 19),
        MicronutrientTarget(name: "Folate", unit: "mcg", dailyValue: 400, category: "Vitamins", displayOrder: 20),
        MicronutrientTarget(name: "Thiamin", unit: "mg", dailyValue: 1.2, category: "Vitamins", displayOrder: 21),
        MicronutrientTarget(name: "Riboflavin", unit: "mg", dailyValue: 1.3, category: "Vitamins", displayOrder: 22),
        MicronutrientTarget(name: "Niacin", unit: "mg", dailyValue: 16, category: "Vitamins", displayOrder: 23)
    ]

    private var consumedMicronutrients: [String: Double] {
        var totals: [String: Double] = [:]

        for meal in mealLogger.getMealsForDate(date) {
            guard let response = meal.nutritionResponse,
                  case .success(let analysis) = response else { continue }

            for item in analysis.breakdown {
                for micro in item.micros {
                    totals[micro.name, default: 0] += micro.value
                }
            }
        }

        return totals
    }

    private var groupedMicronutrients: [(String, String, [(MicronutrientTarget, Double, Double)])] {
        let categories: [(String, String)] = [
            ("Fiber & Fats", "drop.fill"),
            ("Minerals", "cube.fill"),
            ("Vitamins", "sparkles")
        ]

        return categories.map { category, icon in
            let micros = micronutrientTargets
                .filter { $0.category == category }
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { target -> (MicronutrientTarget, Double, Double) in
                    let consumed = consumedMicronutrients[target.name] ?? 0
                    let percentage = min((consumed / target.dailyValue) * 100, 100)
                    return (target, consumed, percentage)
                }
            return (category, icon, micros)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(groupedMicronutrients, id: \.0) { category, icon, micros in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: icon)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)

                                Text(category)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                            }
                            .padding(.horizontal, 4)

                            ForEach(micros, id: \.0.name) { target, consumed, percentage in
                                microRow(target: target, consumed: consumed, percentage: percentage)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .scrollIndicators(.visible)
            .background(Color.appBackground)
            .navigationTitle("Daily Micros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func microRow(target: MicronutrientTarget, consumed: Double, percentage: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(target.name)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Text(String(format: consumed < 10 ? "%.1f" : "%.0f", consumed))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(target.unit)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("•")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(.tertiary)
                    Text("\(Int(percentage))%")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(percentageColor(percentage))
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.1))

                    Capsule()
                        .fill(percentageColor(percentage))
                        .frame(width: geo.size.width * (percentage / 100))
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
    }

    private func percentageColor(_ percentage: Double) -> Color {
        if percentage < 25 {
            return .red
        } else if percentage < 75 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    MicronutrientsSheet(date: Date())
}
