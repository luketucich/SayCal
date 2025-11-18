import SwiftUI

// Onboarding step 5: Set macro percentages
// Shows recommended macro split based on goal, allows manual customization
struct MacrosView: View {
    @ObservedObject var state: OnboardingState

    // Track if macros have been manually overridden
    @State private var isManualOverride = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header section
                    OnboardingHeader(
                        title: "Macro split",
                        subtitle: "Set your macronutrient targets"
                    )

                    // Macro percentages display
                    VStack(spacing: 16) {
                        // Visual macro split bar
                        HStack(spacing: 0) {
                            // Carbs
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: macroBarWidth(for: state.carbsPercent))

                            // Fats
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: macroBarWidth(for: state.fatsPercent))

                            // Protein
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: macroBarWidth(for: state.proteinPercent))
                        }
                        .frame(height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        // Macro sliders
                        VStack(spacing: 20) {
                            MacroSlider(
                                label: "Carbs",
                                percentage: $state.carbsPercent,
                                color: .blue,
                                onChange: { isManualOverride = true }
                            )

                            MacroSlider(
                                label: "Fats",
                                percentage: $state.fatsPercent,
                                color: .orange,
                                onChange: { isManualOverride = true }
                            )

                            MacroSlider(
                                label: "Protein",
                                percentage: $state.proteinPercent,
                                color: .green,
                                onChange: { isManualOverride = true }
                            )
                        }
                        .padding(.top, 8)

                        // Total validation
                        let total = state.carbsPercent + state.fatsPercent + state.proteinPercent
                        HStack {
                            Image(systemName: total == 100 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(total == 100 ? .green : .orange)

                            Text(total == 100 ? "Total: 100%" : "Total: \(total)% (must equal 100%)")
                                .font(.system(size: 13))
                                .foregroundColor(total == 100 ? Color(UIColor.secondaryLabel) : .orange)
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray6))
                    )

                    // Reset to recommended button (only show if manually overridden)
                    if isManualOverride {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                let recommended = state.goal.recommendedMacros
                                state.carbsPercent = recommended.carbs
                                state.fatsPercent = recommended.fats
                                state.proteinPercent = recommended.protein
                                isManualOverride = false
                            }
                            HapticManager.shared.light()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 14, weight: .medium))

                                Text("Reset to recommended for \(state.goal.displayName)")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                    }

                    // Info section explaining recommended macros
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)

                            Text("Recommended for your goal")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(UIColor.label))
                        }

                        Text(getMacroExplanation())
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .fixedSize(horizontal: false, vertical: true)

                        Text("You can customize these percentages or change them later in your profile.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                    )

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            // Bottom button area
            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Set recommended macros based on goal when view appears
            if !isManualOverride {
                let recommended = state.goal.recommendedMacros
                state.carbsPercent = recommended.carbs
                state.fatsPercent = recommended.fats
                state.proteinPercent = recommended.protein
            }
        }
    }

    // Calculate width for macro bar
    private func macroBarWidth(for percentage: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 80 // Account for padding
        return screenWidth * CGFloat(percentage) / 100.0
    }

    // Get explanation for macro recommendations based on goal
    private func getMacroExplanation() -> String {
        switch state.goal {
        case .loseWeight:
            return "For weight loss, we recommend higher protein (40%) to preserve muscle mass, moderate fats (30%) for satiety, and lower carbs (30%) to create a calorie deficit."
        case .maintainWeight:
            return "For weight maintenance, we recommend a balanced split: 40% carbs for energy, 30% protein for muscle maintenance, and 30% fats for overall health."
        case .buildMuscle:
            return "For muscle building, we recommend higher protein (35%) for muscle synthesis, moderate-high carbs (40%) for workout energy, and moderate fats (25%)."
        case .gainWeight:
            return "For weight gain, we recommend higher carbs (45%) for energy and calories, moderate protein (30%) for muscle growth, and moderate fats (25%)."
        }
    }
}

// Macro slider component
struct MacroSlider: View {
    let label: String
    @Binding var percentage: Int
    let color: Color
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)

                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(UIColor.label))

                Spacer()

                Text("\(percentage)%")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 50, alignment: .trailing)
            }

            Slider(
                value: Binding(
                    get: { Double(percentage) },
                    set: { newValue in
                        percentage = Int(newValue)
                        onChange()
                    }
                ),
                in: 0...100,
                step: 5
            )
            .tint(color)
        }
    }
}

#Preview {
    MacrosView(state: OnboardingState())
}
