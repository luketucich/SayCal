import SwiftUI

struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your units")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Select your preferred measurement system")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Form {
                Section {
                    Picker("Units", selection: $state.unitsPreference) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Metric")
                                    .font(.headline)
                                Text("Kilograms • Centimeters")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "")
                        }
                        .tag(UnitsPreference.metric)

                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Imperial")
                                    .font(.headline)
                                Text("Pounds • Feet & Inches")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "")
                        }
                        .tag(UnitsPreference.imperial)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))

            Spacer()

            // Navigation button
            VStack(spacing: 0) {
                Divider()

                HStack {
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
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
