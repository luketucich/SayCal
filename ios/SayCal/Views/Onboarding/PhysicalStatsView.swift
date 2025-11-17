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

                    // Age slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Age")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(state.age)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.accentColor)
                        }

                        Slider(value: Binding(
                            get: { Double(state.age) },
                            set: { state.age = Int($0) }
                        ), in: 13...120, step: 1)
                        .tint(.accentColor)
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

                    // Weight slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Weight")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            if state.unitsPreference == .metric {
                                Text(String(format: "%.1f kg", state.weightKg))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.accentColor)
                            } else {
                                Text(String(format: "%.1f lbs", state.weightLbs))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.accentColor)
                            }
                        }

                        if state.unitsPreference == .metric {
                            // Slider for weight in kg (20-500 kg)
                            Slider(value: $state.weightKg, in: 20...500, step: 0.5)
                                .tint(.accentColor)
                        } else {
                            // Slider for weight in lbs (44-1100 lbs)
                            Slider(value: $state.weightLbs, in: 44...1100, step: 1)
                                .tint(.accentColor)
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
