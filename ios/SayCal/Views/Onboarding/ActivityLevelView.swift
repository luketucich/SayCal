import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xxl) {
                    OnboardingHeader(
                        title: "Activity level",
                        subtitle: "How active are you on a typical day?"
                    )

                    VStack(spacing: DSSpacing.sm) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            SelectableCard(
                                title: level.displayName,
                                isSelected: state.activityLevel == level
                            ) {
                                withAnimation(DSAnimation.quick) {
                                    state.activityLevel = level
                                }
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DSSpacing.lg)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
