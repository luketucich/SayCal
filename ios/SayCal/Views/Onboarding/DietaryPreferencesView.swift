import SwiftUI

/// Step 5: Collects user's dietary preferences (optional)
/// Multiple selections allowed - used for meal planning and recommendations
struct DietaryPreferencesView: View {
    @ObservedObject var state: OnboardingState
    @FocusState private var isTextFieldFocused: Bool
    @State var dietaryPreferences: [String] = DietaryOptions.dietaryPreferences
    @State var isAddingPreference: Bool = false
    @State var newPreference: String = ""

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
                    if (isAddingPreference){
                        TextField("Placeholder text here", text: $newPreference)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                // Trim whitespace and check if not empty
                                let trimmed = newPreference.trimmingCharacters(in: .whitespaces)

                                guard !trimmed.isEmpty else {
                                    // Don't add empty strings
                                    isAddingPreference = false
                                    newPreference = ""
                                    return
                                }

                                // Don't add if it already exists (case-insensitive check)
                                guard !dietaryPreferences.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
                                    isAddingPreference = false
                                    newPreference = ""
                                    return
                                }

                                dietaryPreferences.insert(trimmed, at: 0)
                                state.selectedDietaryPreferences.insert(trimmed)
                                isAddingPreference = false
                                newPreference = ""
                            }
                    }

                    ForEach(dietaryPreferences, id: \.self) { preference in
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

                    Button("Add another preference") {
                        withAnimation {
                            isAddingPreference = true
                            isTextFieldFocused = true
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
