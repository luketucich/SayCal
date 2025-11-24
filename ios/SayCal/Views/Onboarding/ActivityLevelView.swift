import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity level")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("How active are you on a typical day?")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Form {
                Section {
                    Picker("Activity Level", selection: $state.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))

            Spacer()

            // Navigation buttons
            VStack(spacing: 0) {
                Divider()

                HStack {
                    Button {
                        HapticManager.shared.light()
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .foregroundStyle(.secondary)
                            .underline()
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    ActivityLevelView(state: OnboardingState())
}
