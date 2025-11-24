import SwiftUI

struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var userManager: UserManager
    @State private var allergies: [String] = DietaryOptions.commonAllergies
    @State private var newAllergy = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Food allergies")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Select any allergies you have (optional)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            if state.selectedAllergies.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)

                    Text("You can skip this step and update allergies later")
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
                    TextField("Add custom allergy", text: $newAllergy)
                        .onSubmit {
                            addCustomAllergy()
                        }

                    if !newAllergy.isEmpty {
                        Button("Add \"\(newAllergy)\"") {
                            addCustomAllergy()
                        }
                    }
                }

                Section {
                    ForEach(allergies, id: \.self) { allergy in
                        Button {
                            HapticManager.shared.light()
                            withAnimation {
                                if state.selectedAllergies.contains(allergy) {
                                    state.selectedAllergies.remove(allergy)
                                } else {
                                    state.selectedAllergies.insert(allergy)
                                }
                            }
                        } label: {
                            HStack {
                                Text(allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if state.selectedAllergies.contains(allergy) {
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
                        Task {
                            do {
                                try await userManager.completeOnboarding(with: state)
                            } catch {
                                print("❌ Failed to complete onboarding: \(error.localizedDescription)")
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Complete Setup")
                                .fontWeight(.semibold)
                            Image(systemName: "checkmark")
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
            let predefinedAllergies = Set(DietaryOptions.commonAllergies)
            let customAllergies = state.selectedAllergies.filter { !predefinedAllergies.contains($0) }

            for customAllergy in customAllergies {
                if !allergies.contains(customAllergy) {
                    allergies.insert(customAllergy, at: 0)
                }
            }
        }
    }

    private func addCustomAllergy() {
        let trimmed = newAllergy.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !allergies.contains(where: { $0.lowercased() == trimmed.lowercased() }) else { return }

        HapticManager.shared.light()
        withAnimation {
            allergies.insert(trimmed, at: 0)
            state.selectedAllergies.insert(trimmed)
            newAllergy = ""
        }
    }
}

#Preview {
    AllergiesView(state: OnboardingState())
        .environmentObject(UserManager.shared)
}
