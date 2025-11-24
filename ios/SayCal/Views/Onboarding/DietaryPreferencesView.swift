import SwiftUI

struct DietaryPreferencesView: View {
    @ObservedObject var state: OnboardingState
    @State private var dietaryPreferences: [String] = DietaryOptions.dietaryPreferences
    @State private var newPreference = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Dietary preferences")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Select any that apply (optional)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            if state.selectedDietaryPreferences.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)

                    Text("You can skip this step and update preferences later")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }

            Form {
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

                Section {
                    ForEach(dietaryPreferences, id: \.self) { preference in
                        Button {
                            HapticManager.shared.light()
                            withAnimation {
                                if state.selectedDietaryPreferences.contains(preference) {
                                    state.selectedDietaryPreferences.remove(preference)
                                } else {
                                    state.selectedDietaryPreferences.insert(preference)
                                }
                            }
                        } label: {
                            HStack {
                                Text(preference.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if state.selectedDietaryPreferences.contains(preference) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))

            Spacer()

            // Navigation buttons
            VStack(spacing: 0) {
                Divider()

                HStack {
                    Button {
                        HapticManager.shared.light()
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .foregroundStyle(.secondary)
                            .underline()
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text(state.selectedDietaryPreferences.isEmpty ? "Skip" : "Next")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
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
