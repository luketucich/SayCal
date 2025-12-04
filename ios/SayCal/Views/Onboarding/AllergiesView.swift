import SwiftUI

struct AllergiesView: View {
    @ObservedObject var state: OnboardingState
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Food allergies")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

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
                        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                        .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color.appBackground)

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
