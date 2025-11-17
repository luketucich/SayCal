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
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Food allergies")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        Text("Select any allergies you have (optional)")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.top, 24)

                    // Allergy grid with pills
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {

                        if isAddingAllergy {
                            TextField("Enter allergy", text: $newAllergy)
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.label))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color(UIColor.systemBackground))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(UIColor.label), lineWidth: 1.5)
                                        )
                                )
                                .focused($isTextFieldFocused)
                                .onSubmit {
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
                            AllergyPill(
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
                        Button {
                            withAnimation {
                                isAddingAllergy = true
                                isTextFieldFocused = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Add")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                    .background(
                                        Capsule()
                                            .fill(Color(UIColor.systemGray6))
                                    )
                            )
                        }
                    }

                    // Skip option
                    if state.selectedAllergies.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text("You can skip this step and update allergies later")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemGray6))
                        )
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            // Bottom button area
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color(UIColor.systemGray5))

                HStack {
                    Button {
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(UIColor.label))
                            .underline()
                    }

                    Spacer()

                    Button {
                        Task {
                            await auth.completeOnboarding(with: state)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Complete Setup")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.label))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// Allergy pill component (matching dietary pill style)
struct AllergyPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(isSelected ? .white : Color(UIColor.label))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AllergiesView(state: OnboardingState())
        .environmentObject(AuthManager())
}
