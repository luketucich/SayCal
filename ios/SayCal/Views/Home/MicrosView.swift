import SwiftUI

struct MicrosView: View {
    @ObservedObject var mealLogger = MealManager.shared
    @Binding var selectedDate: Date

    // Daily values based on FDA guidelines and RDA
    private let micronutrientTargets: [MicronutrientTarget] = [
        // Macronutrient Components
        MicronutrientTarget(name: "Fiber", unit: "g", dailyValue: 28, category: "Dietary Details", displayOrder: 1),
        MicronutrientTarget(name: "Sugar", unit: "g", dailyValue: 50, category: "Dietary Details", displayOrder: 2),
        MicronutrientTarget(name: "Added Sugars", unit: "g", dailyValue: 25, category: "Dietary Details", displayOrder: 3),
        MicronutrientTarget(name: "Saturated Fat", unit: "g", dailyValue: 20, category: "Dietary Details", displayOrder: 4),
        MicronutrientTarget(name: "Cholesterol", unit: "mg", dailyValue: 300, category: "Dietary Details", displayOrder: 5),

        // Major Minerals
        MicronutrientTarget(name: "Sodium", unit: "mg", dailyValue: 2300, category: "Minerals", displayOrder: 6),
        MicronutrientTarget(name: "Calcium", unit: "mg", dailyValue: 1000, category: "Minerals", displayOrder: 7),
        MicronutrientTarget(name: "Iron", unit: "mg", dailyValue: 18, category: "Minerals", displayOrder: 8),
        MicronutrientTarget(name: "Potassium", unit: "mg", dailyValue: 3500, category: "Minerals", displayOrder: 9),
        MicronutrientTarget(name: "Magnesium", unit: "mg", dailyValue: 400, category: "Minerals", displayOrder: 10),
        MicronutrientTarget(name: "Phosphorus", unit: "mg", dailyValue: 700, category: "Minerals", displayOrder: 11),
        MicronutrientTarget(name: "Zinc", unit: "mg", dailyValue: 11, category: "Minerals", displayOrder: 12),
        MicronutrientTarget(name: "Selenium", unit: "mcg", dailyValue: 55, category: "Minerals", displayOrder: 13),

        // Vitamins
        MicronutrientTarget(name: "Vitamin A", unit: "mcg", dailyValue: 900, category: "Vitamins", displayOrder: 14),
        MicronutrientTarget(name: "Vitamin C", unit: "mg", dailyValue: 90, category: "Vitamins", displayOrder: 15),
        MicronutrientTarget(name: "Vitamin D", unit: "mcg", dailyValue: 20, category: "Vitamins", displayOrder: 16),
        MicronutrientTarget(name: "Vitamin E", unit: "mg", dailyValue: 15, category: "Vitamins", displayOrder: 17),
        MicronutrientTarget(name: "Vitamin K", unit: "mcg", dailyValue: 120, category: "Vitamins", displayOrder: 18),
        MicronutrientTarget(name: "Vitamin B6", unit: "mg", dailyValue: 1.7, category: "Vitamins", displayOrder: 19),
        MicronutrientTarget(name: "Vitamin B12", unit: "mcg", dailyValue: 2.4, category: "Vitamins", displayOrder: 20),
        MicronutrientTarget(name: "Folate", unit: "mcg", dailyValue: 400, category: "Vitamins", displayOrder: 21),
        MicronutrientTarget(name: "Thiamin", unit: "mg", dailyValue: 1.2, category: "Vitamins", displayOrder: 22),
        MicronutrientTarget(name: "Riboflavin", unit: "mg", dailyValue: 1.3, category: "Vitamins", displayOrder: 23),
        MicronutrientTarget(name: "Niacin", unit: "mg", dailyValue: 16, category: "Vitamins", displayOrder: 24)
    ]

    private var consumedMicronutrients: [String: Double] {
        var totals: [String: Double] = [:]

        for meal in mealLogger.getMealsForDate(selectedDate) {
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

    private var generateReportCard: some View {
        Button {
            HapticManager.shared.medium()
            // TODO: Implement premium check and report generation
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Generate Report")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("Get AI insights on your nutrition")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            .padding(20)
            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 20))
            .cardShadow()
        }
        .buttonStyle(.plain)
    }

    private var groupedMicronutrients: [(String, String, [(MicronutrientTarget, Double, Double)])] {
        let categories: [(String, String)] = [
            ("Dietary Details", "drop.fill"),
            ("Minerals", "cube.fill"),
            ("Vitamins", "sparkles")
        ]

        return categories.map { category, icon in
            let micros = micronutrientTargets
                .filter { $0.category == category }
                .sorted { $0.displayOrder < $1.displayOrder }
                .map { target -> (MicronutrientTarget, Double, Double) in
                    let consumed = consumedMicronutrients[target.name] ?? 0
                    let percentage = (consumed / target.dailyValue) * 100
                    return (target, consumed, percentage)
                }
            return (category, icon, micros)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date selector
                DateSelectorView(selectedDate: $selectedDate)
                    .padding(.top, 8)

                // Generate Report Card
                generateReportCard
                    .padding(.horizontal, 16)

                VStack(spacing: 28) {
                    ForEach(groupedMicronutrients, id: \.0) { category, icon, micros in
                        categorySection(category: category, icon: icon, micros: micros)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 100)
            }
        }
        .background(Color.appBackground)
    }

    private func categorySection(category: String, icon: String, micros: [(MicronutrientTarget, Double, Double)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
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

            // Special layout for Dietary Details
            if category == "Dietary Details" {
                dietaryDetailsGrid(micros: micros)
            } else {
                // Standard micronutrient rows
                ForEach(micros, id: \.0.name) { target, consumed, percentage in
                    microRow(target: target, consumed: consumed, percentage: percentage)
                }
            }
        }
    }

    private func dietaryDetailsGrid(micros: [(MicronutrientTarget, Double, Double)]) -> some View {
        let fiber = micros.first { $0.0.name == "Fiber" }
        let sugar = micros.first { $0.0.name == "Sugar" }
        let addedSugars = micros.first { $0.0.name == "Added Sugars" }
        let saturatedFat = micros.first { $0.0.name == "Saturated Fat" }
        let cholesterol = micros.first { $0.0.name == "Cholesterol" }

        return LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            // Fiber
            if let fiber = fiber {
                circularMicroCard(target: fiber.0, consumed: fiber.1, percentage: fiber.2)
            }

            // Combined Sugar card
            if let sugar = sugar, let addedSugars = addedSugars {
                combinedSugarCard(sugar: sugar, addedSugars: addedSugars)
            }

            // Saturated Fat
            if let saturatedFat = saturatedFat {
                circularMicroCard(target: saturatedFat.0, consumed: saturatedFat.1, percentage: saturatedFat.2)
            }

            // Cholesterol
            if let cholesterol = cholesterol {
                circularMicroCard(target: cholesterol.0, consumed: cholesterol.1, percentage: cholesterol.2)
            }
        }
    }

    private func circularMicroCard(target: MicronutrientTarget, consumed: Double, percentage: Double) -> some View {
        VStack(spacing: 12) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 8)
                    .frame(width: 80, height: 80)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(percentage / 100, 1.0))
                    .stroke(percentageColor(percentage), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                // Center text
                VStack(spacing: 2) {
                    Text(String(format: consumed < 10 ? "%.1f" : "%.0f", consumed))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(target.unit)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 2) {
                Text(target.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("\(Int(percentage))%")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(percentageColor(percentage))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 16))
        .cardShadow()
    }

    private func combinedSugarCard(sugar: (MicronutrientTarget, Double, Double), addedSugars: (MicronutrientTarget, Double, Double)) -> some View {
        HStack {
            // Sugar (top)
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 6)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: min(sugar.2 / 100, 1.0))
                        .stroke(percentageColor(sugar.2), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text(String(format: sugar.1 < 10 ? "%.1f" : "%.0f", sugar.1))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(sugar.0.unit)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Sugar")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("\(Int(sugar.2))%")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(percentageColor(sugar.2))
            }

            Divider()
                .padding(.horizontal, 8)

            // Added Sugars (bottom)
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 6)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: min(addedSugars.2 / 100, 1.0))
                        .stroke(percentageColor(addedSugars.2), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text(String(format: addedSugars.1 < 10 ? "%.1f" : "%.0f", addedSugars.1))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(addedSugars.0.unit)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Added Sugars")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("\(Int(addedSugars.2))%")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(percentageColor(addedSugars.2))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 16))
        .cardShadow()
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
                        .frame(width: geo.size.width * min(percentage, 100) / 100)
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
    MicrosView(selectedDate: .constant(Date()))
}
