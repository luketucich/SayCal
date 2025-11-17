import SwiftUI

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

                    // Age input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        TextField("Enter your age", text: $state.age)
                            .keyboardType(.numberPad)
                            .font(.system(size: 17))
                            .padding()
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                            )
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

                    // Weight input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)

                        if state.unitsPreference == .metric {
                            TextField("Enter weight in kg", text: $state.weightKg)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17))
                                .padding()
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                )
                        } else {
                            TextField("Enter weight in lbs", text: $state.weightLbs)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17))
                                .padding()
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                )
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
