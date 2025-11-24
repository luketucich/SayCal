import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Your physical stats")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("We'll use this to calculate your caloric needs")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Form {
                Section {
                    Picker("Sex", selection: $state.sex) {
                        Text("Male").tag(Sex.male)
                        Text("Female").tag(Sex.female)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Picker("Age", selection: $state.age) {
                        ForEach(13..<121, id: \.self) { age in
                            Text("\(age) years").tag(age)
                        }
                    }
                }

                Section {
                    if state.unitsPreference == .metric {
                        Picker("Height", selection: $state.heightCm) {
                            ForEach(100..<251, id: \.self) { cm in
                                Text("\(cm) cm").tag(cm)
                            }
                        }

                        Stepper("Weight: \(String(format: "%.1f", state.weightKg)) kg", value: $state.weightKg, in: 30...300, step: 0.5)
                    } else {
                        Picker("Height", selection: $state.heightCm) {
                            ForEach(100..<251, id: \.self) { cm in
                                let (ft, inch) = cm.cmToFeetAndInches
                                Text("\(ft)' \(inch)\"").tag(cm)
                            }
                        }

                        Stepper("Weight: \(Int(state.weightKg.kgToLbs)) lbs", value: $state.weightKg, in: 30...300, step: 0.5)
                    }
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
    NavigationStack {
        PhysicalStatsView(state: OnboardingState())
    }
}
