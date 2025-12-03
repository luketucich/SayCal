import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your units")
                    .font(.system(size: 28, weight: .bold))

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
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 20)
                        .onChange(of: state.unitsPreference) { _, _ in
                            HapticManager.shared.light()
                        }

                    Spacer()
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))

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
