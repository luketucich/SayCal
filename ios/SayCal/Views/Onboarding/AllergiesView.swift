import SwiftUI

struct AllergiesView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food allergies")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Select any allergies you have (optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(DietaryOptions.commonAllergies, id: \.self) { allergy in
                        MultiSelectCard(
                            title: allergy.replacingOccurrences(of: "_", with: " ").capitalized,
                            isSelected: state.selectedAllergies.contains(allergy)
                        ) {
                            if state.selectedAllergies.contains(allergy) {
                                state.selectedAllergies.remove(allergy)
                            } else {
                                state.selectedAllergies.insert(allergy)
                            }
                        }
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Complete Setup",
                        isEnabled: state.canProceed
                    ) {
                        // This will be hooked up later to save the profile
                        // For now, just a placeholder
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
    AllergiesView(state: OnboardingState())
}
