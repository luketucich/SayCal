import SwiftUI

struct DietaryPreferencesView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dietary preferences")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Select any that apply (optional)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 20) {
                    DietaryPreferencesPickerContent(selectedPreferences: $state.selectedDietaryPreferences)
                        .padding(16)
                        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                        .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color.appBackground)

            OnboardingFooter(
                nextLabel: state.selectedDietaryPreferences.isEmpty ? "Skip" : "Next",
                onBack: { state.previousStep() }
            ) {
                state.nextStep()
            }
        }
    }
}

#Preview {
    NavigationStack {
        DietaryPreferencesView(state: OnboardingState())
    }
}
