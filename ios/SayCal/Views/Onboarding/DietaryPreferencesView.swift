import SwiftUI

struct DietaryPreferencesView: View {
    @ObservedObject var state: OnboardingState
    @State private var dietaryPreferences: [String] = DietaryOptions.dietaryPreferences
    @State private var newPreference = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dietary preferences")
                    .font(.system(size: 28, weight: .bold))

                Text("Select any that apply (optional)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            List {
                Section {
                    TextField("Add custom preference", text: $newPreference)
                        .onSubmit {
                            addCustomPreference()
                        }

                    if !newPreference.isEmpty {
                        Button("Add \"\(newPreference)\"") {
                            addCustomPreference()
                        }
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    ForEach(dietaryPreferences, id: \.self) { preference in
                        Button {
                            HapticManager.shared.light()
                            if state.selectedDietaryPreferences.contains(preference) {
                                state.selectedDietaryPreferences.remove(preference)
                            } else {
                                state.selectedDietaryPreferences.insert(preference)
                            }
                        } label: {
                            HStack {
                                Text(preference.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if state.selectedDietaryPreferences.contains(preference) {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)

            OnboardingFooter(
                nextLabel: state.selectedDietaryPreferences.isEmpty ? "Skip" : "Next",
                onBack: { state.previousStep() }
            ) {
                state.nextStep()
            }
        }
        .onAppear {
            let predefinedPreferences = Set(DietaryOptions.dietaryPreferences)
            let customPreferences = state.selectedDietaryPreferences.filter { !predefinedPreferences.contains($0) }

            for customPref in customPreferences {
                if !dietaryPreferences.contains(customPref) {
                    dietaryPreferences.insert(customPref, at: 0)
                }
            }
        }
    }

    private func addCustomPreference() {
        let trimmed = newPreference.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !dietaryPreferences.contains(where: { $0.lowercased() == trimmed.lowercased() }) else { return }

        HapticManager.shared.light()
        withAnimation {
            dietaryPreferences.insert(trimmed, at: 0)
            state.selectedDietaryPreferences.insert(trimmed)
            newPreference = ""
        }
    }
}

#Preview {
    NavigationStack {
        DietaryPreferencesView(state: OnboardingState())
    }
}
