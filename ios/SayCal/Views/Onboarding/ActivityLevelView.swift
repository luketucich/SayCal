import SwiftUI

/// Step 3: Collects user's daily activity level
/// Activity level is used to calculate TDEE (Total Daily Energy Expenditure)
struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity level")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        Text("How active are you on a typical day?")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.top, 24)

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
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color(UIColor.systemGray5))

                HStack {
                    Button {
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(UIColor.label))
                            .underline()
                    }

                    Spacer()

                    Button {
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.label))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
