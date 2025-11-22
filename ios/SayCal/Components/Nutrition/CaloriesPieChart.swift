import SwiftUI
import Charts

struct CaloriesPieChart: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var userManager: UserManager

    var proteinColor: Color = .blue
    var carbsColor: Color = .green
    var fatsColor: Color = .orange
    var remainingCalories: Int = 1847

    @State private var animateSegments: Bool = false
    
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
            
            ZStack {
                // Outer container circle
                Circle()
                    .stroke(Color.primary.opacity(DesignTokens.Opacity.veryLight), lineWidth: DesignTokens.StrokeWidth.thin)

                // Macro segments
                macroSegments(size: size)

                // Inner ring
                innerRing(size: size)

                // Center content
                centerContent(size: size)

                // Macro labels
                macroLabels(size: size)
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                animateSegments = true
            }
        }
    }
    
    // MARK: - Macro Segments
    private func macroSegments(size: CGFloat) -> some View {
        ZStack {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                let start = startAngle(for: index)
                let end = start + Angle.degrees(macro.value * 360)
                
                Circle()
                    .trim(
                        from: start.degrees / 360,
                        to: animateSegments ? end.degrees / 360 : start.degrees / 360
                    )
                    .stroke(
                        macro.color,
                        style: StrokeStyle(
                            lineWidth: size * 0.08,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding(size * 0.12)
    }
    
    // MARK: - Inner Ring
    private func innerRing(size: CGFloat) -> some View {
        Circle()
            .stroke(
                Color.primary.opacity(DesignTokens.Opacity.veryLight),
                style: StrokeStyle(
                    lineWidth: DesignTokens.StrokeWidth.thin,
                    lineCap: .round
                )
            )
            .padding(size * 0.21)
    }
    
    // MARK: - Center Content
    private func centerContent(size: CGFloat) -> some View {
        VStack(spacing: size * 0.02) {
            Text("\(remainingCalories)")
                .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)

            Text("calories left")
                .font(.system(size: size * 0.055, weight: .medium))
                .foregroundStyle(Color.primary.opacity(DesignTokens.Opacity.strong))

            Text("of \(totalCalories)")
                .font(.system(size: size * 0.045, weight: .medium))
                .foregroundStyle(Color.primary.opacity(DesignTokens.Opacity.medium))
        }
    }
    
    // MARK: - Macro Labels
    private func macroLabels(size: CGFloat) -> some View {
        ZStack {
            ForEach(Array(macroData.enumerated()), id: \.offset) { index, macro in
                let angle = midAngle(for: index)
                let radius = size / 2 - size * 0.045
                
                HStack(spacing: size * 0.02) {
                    Circle()
                        .fill(macro.color)
                        .frame(width: size * 0.025, height: size * 0.025)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(macro.name)
                            .font(.system(size: size * 0.04, weight: .medium))
                            .foregroundStyle(Color.primary)

                        Text("\(Int(macro.value * 100))%")
                            .font(.system(size: size * 0.035, weight: .regular))
                            .foregroundStyle(Color.primary.opacity(DesignTokens.Opacity.strong))
                    }
                }
                .padding(.horizontal, size * 0.025)
                .padding(.vertical, size * 0.02)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                        .fill(colorScheme == .dark ? Color.black : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                                .stroke(Color.primary.opacity(DesignTokens.Opacity.veryLight), lineWidth: DesignTokens.StrokeWidth.thin)
                        )
                )
                .offset(
                    x: cos(angle.radians - .pi / 2) * radius,
                    y: sin(angle.radians - .pi / 2) * radius
                )
                .opacity(animateSegments ? 1 : 0)
                .scaleEffect(animateSegments ? 1 : 0.8)
            }
        }
    }
    
    // MARK: - Helpers
    private func startAngle(for index: Int) -> Angle {
        let previous = macroData.prefix(index).reduce(0.0) { $0 + $1.value }
        return Angle.degrees(previous * 360)
    }

    private func midAngle(for index: Int) -> Angle {
        Angle.degrees(startAngle(for: index).degrees + macroData[index].value * 180)
    }
}

#Preview {
    CaloriesPieChart(
        remainingCalories: 1847
    )
    .frame(width: 300, height: 300)
    .padding()
}
