import SwiftUI

/// Step 6: Collects user's food allergies (optional)
/// Final step - triggers profile creation when "Complete Setup" is pressed
struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var auth: AuthManager
    @FocusState private var isTextFieldFocused: Bool
    @State var allergies: [String] = DietaryOptions.commonAllergies
    @State var isAddingAllergy: Bool = false
    @State var newAllergy: String = ""

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
                    if (isAddingAllergy){
                        // TODO: Validate user input & add this same button to dietary preferences view
                        TextField("Placeholder text here", text: $newAllergy)
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
                                let trimmed = newAllergy.trimmingCharacters(in: .whitespaces)
                                
                                guard !trimmed.isEmpty else {
                                    // Don't add empty strings
                                    isAddingAllergy = false
                                    newAllergy = ""
                                    return
                                }
                                
                                // Don't add if it already exists (case-insensitive check)
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
                    
                    Button("Add another allergy") {
                        withAnimation {
                            isAddingAllergy = true
                            isTextFieldFocused = true
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
