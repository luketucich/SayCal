import SwiftUI

/// Step 5: Dietary preferences
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dietary preferences")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Select any that apply (optional)")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.top, 24)
                    
                    // Preference grid with pills
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        
                        if isAddingPreference {
                            TextField("Enter preference", text: $newPreference)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.black, lineWidth: 1.5)
                                        )
                                )
                                .focused($isTextFieldFocused)
                                .onSubmit {
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
                                }
                        }
                        
                        ForEach(dietaryPreferences, id: \.self) { preference in
                            DietaryPill(
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
                        Button {
                            withAnimation {
                                isAddingPreference = true
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
                    if state.selectedDietaryPreferences.isEmpty {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                            
                            Text("You can skip this step and update preferences later")
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
                            .foregroundColor(.black)
                            .underline()
                    }
                    
                    Spacer()
                    
                    Button {
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text(state.selectedDietaryPreferences.isEmpty ? "Skip" : "Next")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// Dietary preference pill
struct DietaryPill: View {
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
                        .foregroundColor(isSelected ? .white : .black)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.black : Color.white)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.black : Color(UIColor.systemGray5), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        DietaryPreferencesView(state: OnboardingState())
    }
}
