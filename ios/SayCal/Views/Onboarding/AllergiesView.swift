// Onboarding step for specifying food allergies

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
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95))
                            ))
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
                                    withAnimation(.snappy(duration: 0.25)) {
                                        isAddingAllergy = false
                                        newAllergy = ""
                                    }
                                    return
                                }

                                guard !allergies.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
                                    withAnimation(.snappy(duration: 0.25)) {
                                        isAddingAllergy = false
                                        newAllergy = ""
                                    }
                                    return
                                }

                                withAnimation(.snappy(duration: 0.3)) {
                                    allergies.insert(trimmed, at: 0)
                                    state.selectedAllergies.insert(trimmed)
                                    isAddingAllergy = false
                                    newAllergy = ""
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }

                        ForEach(allergies, id: \.self) { allergy in
                            TogglePill(
                                title: allergy.replacingOccurrences(of: "_", with: " ").capitalized,
                                isSelected: state.selectedAllergies.contains(allergy)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if state.selectedAllergies.contains(allergy) {
                                        state.selectedAllergies.remove(allergy)
                                    } else {
                                        state.selectedAllergies.insert(allergy)
                                    }
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                        }

                        // Add button
                        AddOptionButton {
                            withAnimation(.snappy(duration: 0.3)) {
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
                hideWhenFocused: isTextFieldFocused || isAddingAllergy,
                onBack: { state.previousStep() },
                onNext: {
                    Task {
                        await auth.completeOnboarding(with: state)
                    }
                }
            )
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Restore custom allergies when navigating back
            let predefinedAllergies = Set(DietaryOptions.commonAllergies)
            let customAllergies = state.selectedAllergies.filter { !predefinedAllergies.contains($0) }

            // Add any custom allergies that aren't already in the local array
            for customAllergy in customAllergies {
                if !allergies.contains(customAllergy) {
                    allergies.insert(customAllergy, at: 0)
                }
            }
        }
    }
}

#Preview {
    AllergiesView(state: OnboardingState())
        .environmentObject(AuthManager())
}
