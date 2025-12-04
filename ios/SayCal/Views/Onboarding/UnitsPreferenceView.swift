import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your units")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Select your preferred measurement system")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 20) {
                    UnitsPickerContent(selection: $state.unitsPreference)
                        .padding(16)
                        .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 10))
        .cardShadow()
                        .padding(.horizontal, 20)
                        .onChange(of: state.unitsPreference) { _, _ in
                            HapticManager.shared.light()
                        }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color.appBackground)

            OnboardingFooter(showBack: false) {
                state.nextStep()
            }
        }
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
