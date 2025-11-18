import SwiftUI

// Onboarding step 5: Let users pick dietary preferences (vegan, keto, etc.)
struct DietaryPreferencesView: View {
    @ObservedObject var state: OnboardingState
    @FocusState private var isTextFieldFocused: Bool
    @State var dietaryPreferences: [String] = DietaryOptions.dietaryPreferences
    @State var isAddingPreference: Bool = false
    @State var newPreference: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    OnboardingHeader(
                        title: "Dietary preferences",
                        subtitle: "Select any that apply (optional)"
                    )

                    // Skip option
                    if state.selectedDietaryPreferences.isEmpty {
                        InfoCallout(message: "You can skip this step and update preferences later")
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                                removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95))
                            ))
                    }

                    // Preference grid with pills
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        
                        if isAddingPreference {
                            CustomInputField(
                                placeholder: "Enter preference",
                                text: $newPreference,
                                isFocused: $isTextFieldFocused
                            ) {
                                let trimmed = newPreference.trimmingCharacters(in: .whitespaces)

                                guard !trimmed.isEmpty else {
                                    withAnimation(.snappy(duration: 0.25)) {
                                        isAddingPreference = false
                                        newPreference = ""
                                    }
                                    return
                                }

                                guard !dietaryPreferences.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
                                    withAnimation(.snappy(duration: 0.25)) {
                                        isAddingPreference = false
                                        newPreference = ""
                                    }
                                    return
                                }

                                withAnimation(.snappy(duration: 0.3)) {
                                    dietaryPreferences.insert(trimmed, at: 0)
                                    state.selectedDietaryPreferences.insert(trimmed)
                                    isAddingPreference = false
                                    newPreference = ""
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                        
                        ForEach(dietaryPreferences, id: \.self) { preference in
                            TogglePill(
                                title: preference.replacingOccurrences(of: "_", with: " ").capitalized,
                                isSelected: state.selectedDietaryPreferences.contains(preference)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if state.selectedDietaryPreferences.contains(preference) {
                                        state.selectedDietaryPreferences.remove(preference)
                                    } else {
                                        state.selectedDietaryPreferences.insert(preference)
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
                                isAddingPreference = true
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
                nextButtonText: state.selectedDietaryPreferences.isEmpty ? "Skip" : "Next",
                hideWhenFocused: isTextFieldFocused || isAddingPreference,
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Restore custom dietary preferences when navigating back
            let predefinedPreferences = Set(DietaryOptions.dietaryPreferences)
            let customPreferences = state.selectedDietaryPreferences.filter { !predefinedPreferences.contains($0) }

            // Add any custom preferences that aren't already in the local array
            for customPref in customPreferences {
                if !dietaryPreferences.contains(customPref) {
                    dietaryPreferences.insert(customPref, at: 0)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DietaryPreferencesView(state: OnboardingState())
    }
}
