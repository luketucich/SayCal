import SwiftUI

/// Step 1: Allows user to choose between metric and imperial units
/// This preference affects how height and weight are displayed throughout the app
struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your units")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select your preferred measurement system")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                SelectableCard(
                    title: "Metric",
                    subtitle: "Kilograms (kg), Centimeters (cm)",
                    isSelected: state.unitsPreference == .metric
                ) {
                    state.unitsPreference = .metric
                }

                SelectableCard(
                    title: "Imperial",
                    subtitle: "Pounds (lbs), Feet/Inches (ft/in)",
                    isSelected: state.unitsPreference == .imperial
                ) {
                    state.unitsPreference = .imperial
                }
            }

            Spacer()

            PrimaryButton(
                title: "Continue",
                isEnabled: state.canProceed
            ) {
                state.nextStep()
            }
        }
        .padding(24)
    }
}

#Preview {
    UnitsPreferenceView(state: OnboardingState())
}
