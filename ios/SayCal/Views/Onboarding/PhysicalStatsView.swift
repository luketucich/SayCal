import SwiftUI

/// Step 2: Collects user's physical stats (sex, age, height, weight)
/// Uses sliders for age and weight for better UX
struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your physical stats")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("This will be used to calculate your caloric needs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 20) {
                    // Sex selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sex")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            SelectableCard(
                                title: "Male",
                                isSelected: state.sex == .male
                            ) {
                                state.sex = .male
                            }

                            SelectableCard(
                                title: "Female",
                                isSelected: state.sex == .female
                            ) {
                                state.sex = .female
                            }
                        }
                    }

                    // Age picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        Picker("Age", selection: $state.age) {
                            ForEach(13...120, id: \.self) { age in
                                Text("\(age) years").tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }

                    // Height input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Height")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        if state.unitsPreference == .metric {
                            Picker("Height (cm)", selection: $state.heightCm) {
                                ForEach(100..<251, id: \.self) { height in
                                    Text("\(height) cm").tag(height)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        } else {
                            HStack(spacing: 12) {
                                Picker("Feet", selection: $state.heightFeet) {
                                    ForEach(4..<8, id: \.self) { feet in
                                        Text("\(feet) ft").tag(feet)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)

                                Picker("Inches", selection: $state.heightInches) {
                                    ForEach(0..<12, id: \.self) { inches in
                                        Text("\(inches) in").tag(inches)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                            }
                            .frame(height: 120)
                        }
                    }

                    // Weight picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        if state.unitsPreference == .metric {
                            // Picker for weight in kg (20-200 kg in 0.5 increments)
                            Picker("Weight (kg)", selection: Binding(
                                get: { Int(state.weightKg * 2) }, // Convert to half-kg units
                                set: { state.weightKg = Double($0) / 2.0 }
                            )) {
                                ForEach(40...400, id: \.self) { halfKg in
                                    let kg = Double(halfKg) / 2.0
                                    Text(String(format: "%.1f kg", kg)).tag(halfKg)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        } else {
                            // Picker for weight in lbs (44-440 lbs)
                            Picker("Weight (lbs)", selection: Binding(
                                get: { Int(state.weightLbs) },
                                set: { state.weightLbs = Double($0) }
                            )) {
                                ForEach(44...440, id: \.self) { lbs in
                                    Text("\(lbs) lbs").tag(lbs)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 120)
                        }
                    }
                }

                PrimaryButton(
                    title: "Continue",
                    isEnabled: state.canProceed
                ) {
                    state.nextStep()
                }
            }
            .padding(24)
        }
    }
}

#Preview {
    PhysicalStatsView(state: OnboardingState())
}
