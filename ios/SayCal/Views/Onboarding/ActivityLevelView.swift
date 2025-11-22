import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sectionSpacing) {
                    OnboardingHeader(
                        title: "Activity level",
                        subtitle: "How active are you on a typical day?"
                    )

                    VStack(spacing: DesignSystem.Spacing.itemSpacing) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            SelectableCard(
                                title: level.displayName,
                                isSelected: state.activityLevel == level
                            ) {
                                state.activityLevel = level
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .screenEdgePadding()
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(DesignSystem.Colors.background)
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
