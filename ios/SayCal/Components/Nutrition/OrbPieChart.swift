import SwiftUI
import Charts

struct OrbPieChart: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var userManager: UserManager

    var proteinColor: Color = .blue
    var carbsColor: Color = .green
    var fatsColor: Color = .orange
    var remainingCalories: Int = 1847

    @State private var tiltX: Double = 0
    @State private var tiltY: Double = 0
    @State private var isDragging: Bool = true
    
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
    
    private var macroData: [(name: String, value: Double, color: Color)] {
        [
            ("Protein", proteinPercent, proteinColor),
            ("Carbs", carbsPercent, carbsColor),
            ("Fats", fatsPercent, fatsColor)
        ]
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            let blurRadii: [CGFloat] = [size * 0.1667, size * 0.2333]
            let ringLineWidth: CGFloat = size * 0.01
            let ringPadding: CGFloat = size * 0.05
            let glowLayers: [CGFloat] = [size * 0.04, size * 0.0333, size * 0.0267, size * 0.02, size * 0.0133]
            let labelOffset: CGFloat = size * 0.15
            let shiftFactor: Double = 0.02

            let primaryHighlightCenter = UnitPoint(
                x: 0.5 - tiltX * shiftFactor,
                y: 0.97 - tiltY * shiftFactor
            )

            let secondaryHighlightCenter = UnitPoint(
                x: 0.6 - tiltX * shiftFactor,
                y: 0.2 - tiltY * shiftFactor
            )

            let shadowCenter = UnitPoint(
                x: 0.5 + tiltX * shiftFactor,
                y: 0.5 + tiltY * shiftFactor
            )
            
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                chartContent(blurRadii: blurRadii, size: size)
                highlightOverlay(size: size, primaryHighlightCenter: primaryHighlightCenter, secondaryHighlightCenter: secondaryHighlightCenter, shadowCenter: shadowCenter)
                percentageRing(glowLayers: glowLayers, lineWidth: ringLineWidth, padding: ringPadding)
                percentageLabels(size: geometry.size, offset: labelOffset)
                    .opacity(isDragging ? 1 : 0)
                    .scaleEffect(isDragging ? 1 : 0.8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                calorieDisplay(size: geometry.size)
            }
            .rotation3DEffect(.degrees(tiltX), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(tiltY), axis: (x: 1, y: 0, z: 0))
            .gesture(dragGesture)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isDragging = false
                    }
                }
            }
        }
    }

    private func chartContent(blurRadii: [CGFloat], size: CGFloat) -> some View {
        ZStack {
            ForEach(blurRadii, id: \.self) { blurRadius in
                Chart(macroData, id: \.name) { macro in
                    SectorMark(angle: .value("Percentage", macro.value))
                        .foregroundStyle(macro.color)
                }
                .chartLegend(.hidden)
                .blur(radius: blurRadius)
                .saturation(1.5)
            }
        }
        .clipShape(Circle())
    }

    private func highlightOverlay(size: CGFloat, primaryHighlightCenter: UnitPoint, secondaryHighlightCenter: UnitPoint, shadowCenter: UnitPoint) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white.opacity(1.0), .white.opacity(0.5), Color.clear]),
                        center: primaryHighlightCenter,
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .blendMode(.screen)
                .blur(radius: size * 0.03)
                .clipShape(Circle())

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white.opacity(0.6), .white.opacity(0.3), Color.clear]),
                        center: secondaryHighlightCenter,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .blendMode(.screen)
                .blur(radius: size * 0.05)
                .clipShape(Circle())

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.black.opacity(0.2), Color.clear]),
                        center: shadowCenter,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .blendMode(.multiply)
                .clipShape(Circle())
        }
    }

    private func percentageRing(glowLayers: [CGFloat], lineWidth: CGFloat, padding: CGFloat) -> some View {
        ZStack {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                let start = startAngle(for: index)
                let end = start + Angle.degrees(macro.value * 360)

                ZStack {
                    ForEach(glowLayers, id: \.self) { glow in
                        Circle()
                            .trim(from: start.degrees / 360, to: end.degrees / 360)
                            .stroke(macro.color.opacity(glow >= (lineWidth * 1.333) ? 0.5 : 0.7), lineWidth: lineWidth)
                            .saturation(1.5)
                            .rotationEffect(.degrees(-90))
                    }

                    Circle()
                        .trim(from: start.degrees / 360, to: end.degrees / 360)
                        .stroke(macro.color, lineWidth: lineWidth)
                        .saturation(1.5)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .padding(isDragging ? -padding : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }

    private func percentageLabels(size: CGSize, offset: CGFloat) -> some View {
        ZStack {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                let angle = midAngle(for: index)
                let radius = size.width / 2 + offset
                
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

    private func calorieDisplay(size: CGSize) -> some View {
        VStack(spacing: size.height * 0.02) {
            Text("\(remainingCalories)")
                .font(.system(size: size.width * 0.213, weight: .bold, design: .rounded))
                .foregroundStyle(Color(UIColor.label))
            
            Text("calories left")
                .font(.system(size: size.width * 0.06, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            
            Text("of \(totalCalories)")
                .font(.system(size: size.width * 0.047, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }

                tiltX = max(-15, min(15, Double(value.translation.width) / 10))
                tiltY = max(-15, min(15, Double(-value.translation.height) / 10))
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    tiltX = 0
                    tiltY = 0
                }


                UIImpactFeedbackGenerator(style: .light).impactOccurred()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isDragging = false
                }
            }
    }

    private func startAngle(for index: Int) -> Angle {
        let previous = macroData.prefix(index).reduce(0.0) { $0 + $1.value }
        return Angle.degrees(previous * 360)
    }

    private func midAngle(for index: Int) -> Angle {
        Angle.degrees(startAngle(for: index).degrees + macroData[index].value * 180)
    }
}

