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

                    HStack(spacing: AppSpacing.sm) {
                        TogglePill(
                            title: "Metric",
                            isSelected: state.unitsPreference == .metric,
                            style: .rounded
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                state.unitsPreference = .metric
                            }
                        }

                        TogglePill(
                            title: "Imperial",
                            isSelected: state.unitsPreference == .imperial,
                            style: .rounded
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
