import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity level")
                    .font(.system(size: 28, weight: .bold))

                Text("How active are you on a typical day?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            List {
                Section {
                    Picker("Activity Level", selection: $state.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.displayName)
                                Text(level.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .onChange(of: state.activityLevel) { _, _ in
                        HapticManager.shared.light()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)

            OnboardingFooter(onBack: { state.previousStep() }) {
                state.nextStep()
            }
        }
    }
}

extension ActivityLevel {
    var description: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderatelyActive: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Hard exercise 6-7 days/week"
        case .extremelyActive: return "Very hard exercise, physical job"
        }
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
