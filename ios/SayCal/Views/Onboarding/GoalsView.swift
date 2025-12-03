import SwiftUI

struct GoalsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showMacrosAsGrams = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your goal")
                    .font(.system(size: 28, weight: .bold))

                Text("What are you trying to achieve?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 20) {
                    CaloriesCard(calories: state.targetCalories, showMacrosAsGrams: $showMacrosAsGrams, goal: state.goal)
                        .padding(.horizontal, 20)

                    GoalPickerContent(selection: $state.goal)
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 20)
                        .onChange(of: state.goal) { _, _ in
                            HapticManager.shared.light()
                        }

                    Spacer()
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))

            OnboardingFooter(onBack: { state.previousStep() }) {
                state.nextStep()
            }
        }
    }
}

struct CaloriesCard: View {
    let calories: Int
    @Binding var showMacrosAsGrams: Bool
    let goal: Goal

    private var macros: (carbs: Int, fats: Int, protein: Int) {
        UserManager.calculateMacroPercentages(for: goal)
    }

    private var carbsGrams: Int { (calories * macros.carbs) / 400 }
    private var fatsGrams: Int { (calories * macros.fats) / 900 }
    private var proteinGrams: Int { (calories * macros.protein) / 400 }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(calories)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text("calories per day")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button {
                HapticManager.shared.light()
                withAnimation(.easeInOut(duration: 0.2)) {
                    showMacrosAsGrams.toggle()
                }
            } label: {
                HStack(spacing: 0) {
                    MacroDisplayItem(
                        title: "Carbs",
                        value: showMacrosAsGrams ? "\(carbsGrams)g" : "\(macros.carbs)%"
                    )
                    MacroDisplayItem(
                        title: "Fat",
                        value: showMacrosAsGrams ? "\(fatsGrams)g" : "\(macros.fats)%"
                    )
                    MacroDisplayItem(
                        title: "Protein",
                        value: showMacrosAsGrams ? "\(proteinGrams)g" : "\(macros.protein)%"
                    )
                }
            }
            .buttonStyle(.plain)

            Text("Tap to toggle grams/percentages")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.tertiarySystemGroupedBackground)))
    }
}

struct MacroDisplayItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
