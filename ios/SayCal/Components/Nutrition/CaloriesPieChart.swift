import SwiftUI
import Charts

struct CaloriesPieChart: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var userManager: UserManager

    var remainingCalories: Int = 1847
    
    private var proteinPercent: Double {
        guard let profile = userManager.profile else { return 0.30 }
        return Double(profile.proteinPercent) / 100.0
    }

    private var carbsPercent: Double {
        guard let profile = userManager.profile else { return 0.40 }
        return Double(profile.carbsPercent) / 100.0
    }

    private var fatsPercent: Double {
        guard let profile = userManager.profile else { return 0.30 }
        return Double(profile.fatsPercent) / 100.0
    }

    private var totalCalories: Int {
        userManager.profile?.targetCalories ?? 2400
    }
    
    private var consumedCalories: Int {
        totalCalories - remainingCalories
    }
    
    private var consumedPercent: Double {
        Double(consumedCalories) / Double(totalCalories)
    }
    
    private var macroData: [(name: String, value: Double, color: Color)] {
        [
            ("Protein", proteinPercent, .blue),
            ("Carbs", carbsPercent, .green),
            ("Fats", fatsPercent, .orange)
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            VStack(spacing: size * 0.08) {
                // Main ring
                mainRing(size: size)
                
                // Macro breakdown below
                macroBreakdown(size: size)
            }
            .frame(width: size, height: size * 1.25)
        }
    }
    
    // MARK: - Main Ring
    private func mainRing(size: CGFloat) -> some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.tertiary,
                    lineWidth: size * 0.06
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: consumedPercent)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.purple
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: size * 0.06,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Center content
            VStack(spacing: size * 0.01) {
                Text("\(remainingCalories)")
                    .font(.system(size: size * 0.14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                Text("left")
                    .font(.system(size: size * 0.045, weight: .regular))
                    .foregroundStyle(Color.secondary)
                
                Text("of \(totalCalories)")
                    .font(.system(size: size * 0.04, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: size * 0.7, height: size * 0.7)
    }
    
    // MARK: - Macro Breakdown
    private func macroBreakdown(size: CGFloat) -> some View {
        HStack(spacing: size * 0.06) {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                VStack(spacing: size * 0.015) {
                    // Grams remaining
                    Text("\(gramsRemaining(for: index))g")
                        .font(.system(size: size * 0.06, weight: .semibold, design: .rounded))
                        .foregroundStyle(macro.color)
                    
                    // Label
                    Text(macro.name)
                        .font(.system(size: size * 0.038, weight: .regular))
                        .foregroundStyle(Color.secondary)
                    
                    // Small indicator bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(macro.color)
                        .frame(width: size * 0.12, height: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, size * 0.04)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.025)
                        .fill(Color.gray.tertiary)
                )
            }
        }
        .padding(.horizontal, size * 0.05)
    }
    
    // MARK: - Helper: Calculate grams remaining
    private func gramsRemaining(for macroIndex: Int) -> Int {
        let macro = macroData[macroIndex]
        let caloriesForMacro = Double(remainingCalories) * macro.value
        
        // Convert calories to grams
        // Protein: 4 cal/g, Carbs: 4 cal/g, Fats: 9 cal/g
        let gramsPerCalorie: Double
        switch macro.name {
        case "Protein", "Carbs":
            gramsPerCalorie = 4.0
        case "Fats":
            gramsPerCalorie = 9.0
        default:
            gramsPerCalorie = 4.0
        }
        
        return Int(caloriesForMacro / gramsPerCalorie)
    }
}

#Preview {
    CaloriesPieChart(
        remainingCalories: 1847
    )
    .environmentObject(UserManager.shared)
    .frame(width: 300, height: 375)
    .padding()
    .background(Color(.systemBackground))
}
