import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your physical stats")
                    .font(.system(size: 28, weight: .bold))

                Text("We'll use this to calculate your caloric needs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            List {
                Section {
                    HStack(spacing: 16) {
                        Text("Sex")
                            .frame(width: 80, alignment: .leading)

                        Picker("Sex", selection: $state.sex) {
                            Text("Male").tag(Sex.male)
                            Text("Female").tag(Sex.female)
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: .infinity)
                    }
                    .onChange(of: state.sex) { _, _ in
                        HapticManager.shared.light()
                    }
                } footer: {
                    Text("Required for accurate calorie calculations based on metabolic differences")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)

                Section {
                    HStack(spacing: 16) {
                        Text("Age")
                            .frame(width: 80, alignment: .leading)

                        Picker("Age", selection: $state.age) {
                            ForEach(13..<121, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 100)
                }.listRowBackground(Color.clear)

                Section {
                    if state.unitsPreference == .metric {
                        HStack(spacing: 16) {
                            Text("Height")
                                .frame(width: 80, alignment: .leading)

                            Picker("Height", selection: $state.heightCm) {
                                ForEach(100..<251, id: \.self) { cm in
                                    Text("\(cm) cm").tag(cm)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 100)
                    } else {
                        HStack(spacing: 16) {
                            Text("Height")
                                .frame(width: 80, alignment: .leading)

                            Picker("Height", selection: $state.heightCm) {
                                ForEach(100..<251, id: \.self) { cm in
                                    let (ft, inch) = cm.cmToFeetAndInches
                                    Text("\(ft)' \(inch)\"").tag(cm)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 100)
                    }
                }.listRowBackground(Color.clear)

                Section {
                    if state.unitsPreference == .metric {
                        HStack(spacing: 16) {
                            Text("Weight")
                                .frame(width: 80, alignment: .leading)

                            Picker("Weight", selection: $state.weightKg) {
                                ForEach(Array(stride(from: 30.0, through: 300.0, by: 0.5)), id: \.self) { weight in
                                    Text(String(format: "%.1f kg", weight)).tag(weight)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 100)
                    } else {
                        HStack(spacing: 16) {
                            Text("Weight")
                                .frame(width: 80, alignment: .leading)

                            Picker("Weight", selection: $state.weightKg) {
                                ForEach(Array(stride(from: 30.0, through: 300.0, by: 0.5)), id: \.self) { weightKg in
                                    let lbs = Int(weightKg.kgToLbs)
                                    Text("\(lbs) lbs").tag(weightKg)
                                }
                            }
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 100)
                    }
                }.listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(0)
            .scrollContentBackground(.hidden)

            OnboardingFooter(onBack: { state.previousStep() }) {
                state.nextStep()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhysicalStatsView(state: OnboardingState())
    }
}
