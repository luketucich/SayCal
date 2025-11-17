import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity level")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("How active are you on a typical day?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    // Workouts per week
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workouts per week")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        HStack {
                            ForEach(0..<8, id: \.self) { count in
                                Button {
                                    state.workoutsPerWeek = count
                                } label: {
                                    Text("\(count)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(state.workoutsPerWeek == count ? .white : .primary)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(state.workoutsPerWeek == count ? Color.accentColor : Color.clear)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(state.workoutsPerWeek == count ? Color.clear : Color.primary.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Activity level selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily activity level")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        VStack(spacing: 12) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                SelectableCard(
                                    title: level.displayName,
                                    isSelected: state.activityLevel == level
                                ) {
                                    state.activityLevel = level
                                }
                            }
                        }
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Continue",
                        isEnabled: state.canProceed
                    ) {
                        state.nextStep()
                    }

                    Button {
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
