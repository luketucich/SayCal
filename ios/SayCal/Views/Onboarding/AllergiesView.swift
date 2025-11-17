import SwiftUI

/// Step 6: Collects user's food allergies (optional)
/// Final step - triggers profile creation when "Complete Setup" is pressed
struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var auth: AuthManager

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
                    // Complete onboarding and create user profile in database
                    PrimaryButton(
                        title: "Complete Setup",
                        isEnabled: state.canProceed
                    ) {
                        Task {
                            await auth.completeOnboarding(with: state)
                        }
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
        .environmentObject(AuthManager())
}
