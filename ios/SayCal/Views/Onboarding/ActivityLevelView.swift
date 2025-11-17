import SwiftUI

/// Step 3: Collects user's daily activity level
/// Activity level is used to calculate TDEE (Total Daily Energy Expenditure)
struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity level")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("How active are you on a typical day?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Activity level selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily activity level")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)

                    VStack(spacing: 12) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            SelectableCard(
                                title: level.displayName,
                                isSelected: state.activityLevel == level
                            ) {
                                state.activityLevel = level
                            }
                        }
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Continue",
                        isEnabled: state.canProceed
                    ) {
                        state.nextStep()
                    }

                    Button {
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
