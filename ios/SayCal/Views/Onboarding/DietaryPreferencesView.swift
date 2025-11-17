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
                                    isAddingPreference = false
                                    newPreference = ""
                                    return
                                }

                                guard !dietaryPreferences.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
                                    isAddingPreference = false
                                    newPreference = ""
                                    return
                                }

                                dietaryPreferences.insert(trimmed, at: 0)
                                state.selectedDietaryPreferences.insert(trimmed)
                                isAddingPreference = false
                                newPreference = ""
                            } onCancel: {
                                isAddingPreference = false
                            }
                        }
                        
                        ForEach(dietaryPreferences, id: \.self) { preference in
                            TogglePill(
                                title: preference.replacingOccurrences(of: "_", with: " ").capitalized,
                                isSelected: state.selectedDietaryPreferences.contains(preference)
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if state.selectedDietaryPreferences.contains(preference) {
                                        state.selectedDietaryPreferences.remove(preference)
                                    } else {
                                        state.selectedDietaryPreferences.insert(preference)
                                    }
                                }
                            }
                        }
                        
                        // Add button
                        AddOptionButton {
                            withAnimation {
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
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    NavigationStack {
        DietaryPreferencesView(state: OnboardingState())
    }
}
