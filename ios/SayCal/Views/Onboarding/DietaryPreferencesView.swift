import SwiftUI

struct DietaryPreferencesView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dietary preferences")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Select any that apply (optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(DietaryOptions.dietaryPreferences, id: \.self) { preference in
                        MultiSelectCard(
                            title: preference.replacingOccurrences(of: "_", with: " ").capitalized,
                            isSelected: state.selectedDietaryPreferences.contains(preference)
                        ) {
                            if state.selectedDietaryPreferences.contains(preference) {
                                state.selectedDietaryPreferences.remove(preference)
                            } else {
                                state.selectedDietaryPreferences.insert(preference)
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
    DietaryPreferencesView(state: OnboardingState())
}
