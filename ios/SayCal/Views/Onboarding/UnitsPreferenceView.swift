import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sectionSpacing) {
                    OnboardingHeader(
                        title: "Choose your units",
                        subtitle: "Select your preferred measurement system"
                    )

                    VStack(spacing: DesignSystem.Spacing.itemSpacing) {
                        UnitCard(
                            title: "Metric",
                            subtitle: "Kilograms • Centimeters",
                            isSelected: state.unitsPreference == .metric
                        ) {
                            state.unitsPreference = .metric
                        }

                        UnitCard(
                            title: "Imperial",
                            subtitle: "Pounds • Feet & Inches",
                            isSelected: state.unitsPreference == .imperial
                        ) {
                            state.unitsPreference = .imperial
                        }
                    }

                    Spacer(minLength: 100)
                }
                .screenEdgePadding()
            }

            OnboardingBottomBar(
                showBackButton: false,
                onNext: { state.nextStep() }
            )
        }
        .background(DesignSystem.Colors.background)
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
