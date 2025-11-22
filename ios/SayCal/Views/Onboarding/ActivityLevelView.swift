import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    OnboardingHeader(
                        title: "Activity level",
                        subtitle: "How active are you on a typical day?"
                    )

                    VStack(spacing: 12) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            SelectableCard(
                                title: level.displayName,
                                isSelected: state.activityLevel == level
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    state.activityLevel = level
                                }
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(AppColors.lightBackground)
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
