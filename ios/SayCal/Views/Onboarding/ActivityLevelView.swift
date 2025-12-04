import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity level")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("How active are you on a typical day?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 20) {
                    ActivityLevelPickerContent(selection: $state.activityLevel)
                        .padding(16)
                        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                        .padding(.horizontal, 20)
                        .onChange(of: state.activityLevel) { _, _ in
                            HapticManager.shared.light()
                        }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color.appBackground)

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
