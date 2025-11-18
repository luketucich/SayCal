import SwiftUI
import Charts

// An interactive 3D-style pie chart that displays macronutrient percentages and remaining calories
struct CaloriesPieChart: View {
    
    // Macro percentages (should total 1.0)
    var proteinPercent: Double = 0.30
    var carbsPercent: Double = 0.40
    var fatsPercent: Double = 0.30
    
    // Customizable colors for each macro
    var proteinColor: Color = .blue
    var carbsColor: Color = .green
    var fatsColor: Color = .orange
    
    // Calorie tracking
    var remainingCalories: Int = 1847
    var totalCalories: Int = 2400
    
    // State for 3D tilt effect
    @State private var tiltX: Double = 0
    @State private var tiltY: Double = 0
    @State private var isDragging: Bool = false
    
    private var macroData: [(name: String, value: Double, color: Color)] {
        [
            ("Protein", proteinPercent, proteinColor),
            ("Carbs", carbsPercent, carbsColor),
            ("Fats", fatsPercent, fatsColor)
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                chartContent
                Circle()
                    .stroke(Color(UIColor.label), lineWidth: 2)
                percentageRing
                percentageLabels(size: geometry.size)
                    .opacity(isDragging ? 1 : 0)
                    .scaleEffect(isDragging ? 1 : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                calorieDisplay(size: geometry.size)
            }
            .rotation3DEffect(.degrees(tiltX), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(tiltY), axis: (x: 1, y: 0, z: 0))
            .gesture(dragGesture)
        }
    }
    
    // Main pie chart with blur layers for depth effect
    private var chartContent: some View {
        ZStack {
            // Multiple blur layers create depth
            ForEach([50, 70], id: \.self) { blur in
                Chart(macroData, id: \.name) { macro in
                    SectorMark(angle: .value("Percentage", macro.value))
                        .foregroundStyle(macro.color)
                }
                .chartLegend(.hidden)
                .blur(radius: CGFloat(blur))
                .saturation(1.3)
            }
        }
        .clipShape(Circle())
    }
    
    // Glowing outer ring around the pie chart
    private var percentageRing: some View {
        ZStack {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                let start = startAngle(for: index)
                let end = start + Angle.degrees(macro.value * 360)
                
                ZStack {
                    // Multiple blur layers create the glow effect
                    ForEach([12, 10, 8, 6, 4], id: \.self) { blur in
                        Circle()
                            .trim(from: start.degrees / 360, to: end.degrees / 360)
                            .stroke(macro.color.opacity(blur >= 8 ? 0.3 : 0.5), lineWidth: 6)
                            .saturation(1.3)
//                            .blur(radius: CGFloat(blur))
                            .rotationEffect(.degrees(-90))
                    }
                    
                    // Solid ring on top
                    Circle()
                        .trim(from: start.degrees / 360, to: end.degrees / 360)
                        .stroke(macro.color.opacity(0.9), lineWidth: 6)
                        .saturation(1.3)
                        .blur(radius: 1)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .padding(-15)
    }
    
    // Percentage labels positioned around the outer ring
    private func percentageLabels(size: CGSize) -> some View {
        ZStack {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                let angle = midAngle(for: index)
                let radius = size.width / 2 + 45
                
                Text("\(Int(macro.value * 100))%")
                    .font(.system(size: size.width * 0.055, weight: .semibold))
                    .foregroundStyle(macro.color)
                    .offset(
                        x: cos(angle.radians - .pi / 2) * radius,
                        y: sin(angle.radians - .pi / 2) * radius
                    )
            }
        }
    }
    
    // Central calorie count display with dynamic sizing
    private func calorieDisplay(size: CGSize) -> some View {
        VStack(spacing: size.height * 0.02) {
            Text("\(remainingCalories)")
                .font(.system(size: size.width * 0.213, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.8), radius: 20)
                .shadow(color: .white.opacity(0.6), radius: 10)
                .shadow(color: .white.opacity(0.4), radius: 5)
            
            Text("calories left")
                .font(.system(size: size.width * 0.06, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.6), radius: 10)
                .shadow(color: .white.opacity(0.4), radius: 5)
            
            Text("of \(totalCalories)")
                .font(.system(size: size.width * 0.047, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.6), radius: 10)
                .shadow(color: .white.opacity(0.4), radius: 5)
        }
    }
    
    // Drag gesture for 3D tilt effect with haptic feedback
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Haptic feedback on first movement
                if !isDragging {
                    isDragging = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                // Update tilt values (clamped to ±15 degrees)
                tiltX = max(-15, min(15, Double(value.translation.width) / 10))
                tiltY = max(-15, min(15, Double(-value.translation.height) / 10))
            }
            .onEnded { _ in
                // Springy see-saw animation back to center
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    tiltX = 0
                    tiltY = 0
                }
                
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                // Keep percentages visible for 1.5 seconds after drag ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isDragging = false
                }
            }
    }
    
    // Calculate starting angle for a macro segment
    private func startAngle(for index: Int) -> Angle {
        let previous = macroData.prefix(index).reduce(0.0) { $0 + $1.value }
        return Angle.degrees(previous * 360)
    }
    
    // Calculate midpoint angle for a macro segment (for label positioning)
    private func midAngle(for index: Int) -> Angle {
        Angle.degrees(startAngle(for: index).degrees + macroData[index].value * 180)
    }
}

#Preview {
    CaloriesPieChart(
        proteinPercent: 0.30,
        carbsPercent: 0.40,
        fatsPercent: 0.30,
        remainingCalories: 1847,
        totalCalories: 2400
    )
    .frame(width: 300, height: 300)
    .padding()
    .background(Color(.systemBackground))
}
