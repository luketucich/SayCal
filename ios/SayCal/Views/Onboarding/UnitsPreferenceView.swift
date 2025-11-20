import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xxl) {
                    OnboardingHeader(
                        title: "Choose your units",
                        subtitle: "Select your preferred measurement system"
                    )

                    VStack(spacing: DSSpacing.sm) {
                        UnitCard(
                            title: "Metric",
                            subtitle: "Kilograms • Centimeters",
                            isSelected: state.unitsPreference == .metric
                        ) {
                            withAnimation(DSAnimation.quick) {
                                state.unitsPreference = .metric
                            }
                        }

                        UnitCard(
                            title: "Imperial",
                            subtitle: "Pounds • Feet & Inches",
                            isSelected: state.unitsPreference == .imperial
                        ) {
                            withAnimation(DSAnimation.quick) {
                                state.unitsPreference = .imperial
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DSSpacing.lg)
            }

            OnboardingBottomBar(
                showBackButton: false,
                onNext: { state.nextStep() }
            )
        }
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
