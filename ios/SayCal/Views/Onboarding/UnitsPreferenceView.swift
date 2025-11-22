import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    OnboardingHeader(
                        title: "Choose your units",
                        subtitle: "Select your preferred measurement system"
                    )

                    VStack(spacing: AppSpacing.sm) {
                        UnitCard(
                            title: "Metric",
                            subtitle: "Kilograms • Centimeters",
                            isSelected: state.unitsPreference == .metric
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                state.unitsPreference = .metric
                            }
                        }
                        
                        UnitCard(
                            title: "Imperial",
                            subtitle: "Pounds • Feet & Inches",
                            isSelected: state.unitsPreference == .imperial
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                state.unitsPreference = .imperial
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppSpacing.lg)
            }

            OnboardingBottomBar(
                showBackButton: false,
                onNext: { state.nextStep() }
            )
        }
        .background(AppColors.lightBackground)
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
