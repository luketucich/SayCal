import SwiftUI

struct GoalsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Your goal")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("What are you trying to achieve?")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Form {
                // Calories & Macros Display
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Target Calories")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Text("\(state.targetCalories)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("calories per day")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    let macros = UserManager.calculateMacroPercentages(for: state.goal)

                    HStack(spacing: 12) {
                        MacroCard(title: "Carbs", percentage: macros.carbs, color: .blue)
                        MacroCard(title: "Fats", percentage: macros.fats, color: .orange)
                        MacroCard(title: "Protein", percentage: macros.protein, color: .green)
                    }
                    .listRowInsets(EdgeInsets())
                } footer: {
                    Label("You can edit your target calories and macros anytime in your profile", systemImage: "info.circle")
                }

                // Goal Picker
                Section {
                    Picker("Goal", selection: $state.goal) {
                        ForEach(Goal.allCases, id: \.self) { goal in
                            VStack(alignment: .leading) {
                                Text(goal.displayName)
                                Text(goal.calorieAdjustmentText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(goal)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))

            Spacer()

            // Navigation buttons
            VStack(spacing: 0) {
                Divider()

                HStack {
                    Button {
                        HapticManager.shared.light()
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .foregroundStyle(.secondary)
                            .underline()
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
    }
}

struct MacroCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("\(percentage)%")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    GoalsView(state: OnboardingState())
}
