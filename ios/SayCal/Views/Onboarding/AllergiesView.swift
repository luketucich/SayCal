import SwiftUI

// Final onboarding step: Track food allergies
// Pressing "Complete Setup" creates the user profile
struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var auth: AuthManager
    @FocusState private var isTextFieldFocused: Bool
    @State var allergies: [String] = DietaryOptions.commonAllergies
    @State var isAddingAllergy: Bool = false
    @State var newAllergy: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header section
                    OnboardingHeader(
                        title: "Food allergies",
                        subtitle: "Select any allergies you have (optional)"
                    )

                    // Skip option
                    if state.selectedAllergies.isEmpty {
                        InfoCallout(message: "You can skip this step and update allergies later")
                    }

                    // Allergy grid with pills
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {

                        if isAddingAllergy {
                            CustomInputField(
                                placeholder: "Enter allergy",
                                text: $newAllergy,
                                isFocused: $isTextFieldFocused
                            ) {
                                let trimmed = newAllergy.trimmingCharacters(in: .whitespaces)

                                guard !trimmed.isEmpty else {
                                    isAddingAllergy = false
                                    newAllergy = ""
                                    return
                                }

                                guard !allergies.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
                                    isAddingAllergy = false
                                    newAllergy = ""
                                    return
                                }

                                allergies.insert(trimmed, at: 0)
                                state.selectedAllergies.insert(trimmed)
                                isAddingAllergy = false
                                newAllergy = ""
                            }
                        }

                        ForEach(allergies, id: \.self) { allergy in
                            TogglePill(
                                title: allergy.replacingOccurrences(of: "_", with: " ").capitalized,
                                isSelected: state.selectedAllergies.contains(allergy)
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if state.selectedAllergies.contains(allergy) {
                                        state.selectedAllergies.remove(allergy)
                                    } else {
                                        state.selectedAllergies.insert(allergy)
                                    }
                                }
                            }
                        }

                        // Add button
                        AddOptionButton {
                            withAnimation {
                                isAddingAllergy = true
                                isTextFieldFocused = true
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            // Bottom button area
            OnboardingBottomBar(
                nextButtonText: "Complete Setup",
                nextButtonIcon: "checkmark",
                onBack: { state.previousStep() },
                onNext: {
                    Task {
                        await auth.completeOnboarding(with: state)
                    }
                }
            )
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    AllergiesView(state: OnboardingState())
        .environmentObject(AuthManager())
}
