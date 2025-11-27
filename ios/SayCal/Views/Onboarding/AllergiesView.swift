import SwiftUI

struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var userManager: UserManager
    @State private var allergies: [String] = DietaryOptions.commonAllergies
    @State private var newAllergy = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Food allergies")
                    .font(.system(size: 28, weight: .bold))

                Text("Select any allergies you have (optional)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            List {
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
                .listRowBackground(Color.clear)

                Section {
                    ForEach(allergies, id: \.self) { allergy in
                        Button {
                            HapticManager.shared.light()
                            if state.selectedAllergies.contains(allergy) {
                                state.selectedAllergies.remove(allergy)
                            } else {
                                state.selectedAllergies.insert(allergy)
                            }
                        } label: {
                            HStack {
                                Text(allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if state.selectedAllergies.contains(allergy) {
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
                nextLabel: "Complete Setup",
                nextIcon: "checkmark",
                onBack: { state.previousStep() }
            ) {
                Task {
                    do {
                        try await userManager.completeOnboarding(with: state)
                    } catch {
                        print("Failed to complete onboarding: \(error.localizedDescription)")
                    }
                }
            }
        }
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
