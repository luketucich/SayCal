import SwiftUI

struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var userManager: UserManager

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

            ScrollView {
                VStack(spacing: 20) {
                    AllergiesPickerContent(selectedAllergies: $state.selectedAllergies)
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))

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
    }
}

#Preview {
    AllergiesView(state: OnboardingState())
        .environmentObject(UserManager.shared)
}
