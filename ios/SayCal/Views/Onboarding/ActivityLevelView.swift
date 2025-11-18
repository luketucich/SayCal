import SwiftUI

// Used to calculate TDEE (daily calorie burn)
struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header section
                    OnboardingHeader(
                        title: "Activity level",
                        subtitle: "How active are you on a typical day?"
                    )

                    // Activity level selection
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

            // Bottom button area
            OnboardingBottomBar(
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
