import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sectionSpacing) {
                    OnboardingHeader(
                        title: "Your physical stats",
                        subtitle: "We'll use this to calculate your caloric needs"
                    )

                    VStack(spacing: DesignSystem.Spacing.xlarge) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Sex")
                                .font(DesignSystem.Typography.captionLarge)
                                .foregroundColor(DesignSystem.Colors.textSecondary)

                            HStack(spacing: DesignSystem.Spacing.itemSpacing) {
                                TogglePill(
                                    title: "Male",
                                    isSelected: state.sex == .male,
                                    style: .rounded
                                ) {
                                    state.sex = .male
                                }

                                TogglePill(
                                    title: "Female",
                                    isSelected: state.sex == .female,
                                    style: .rounded
                                ) {
                                    state.sex = .female
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Age")
                                .font(DesignSystem.Typography.captionLarge)
                                .foregroundColor(DesignSystem.Colors.textSecondary)

                            FormPickerButton(label: "\(state.age) years") {
                                HapticManager.shared.light()
                                showAgePicker.toggle()
                            }
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Height")
                                .font(DesignSystem.Typography.captionLarge)
                                .foregroundColor(DesignSystem.Colors.textSecondary)

                            FormPickerButton(
                                label: state.unitsPreference == .metric
                                    ? "\(state.heightCm) cm"
                                    : "\(state.heightFeet)' \(state.heightInches)\""
                            ) {
                                HapticManager.shared.light()
                                showHeightPicker.toggle()
                            }
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Weight")
                                .font(DesignSystem.Typography.captionLarge)
                                .foregroundColor(DesignSystem.Colors.textSecondary)

                            FormPickerButton(
                                label: state.unitsPreference == .metric
                                    ? String(format: "%.1f kg", state.weightKg)
                                    : "\(Int(state.weightLbs)) lbs"
                            ) {
                                HapticManager.shared.light()
                                showWeightPicker.toggle()
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .screenEdgePadding()
            }

            OnboardingBottomBar(
                isNextEnabled: state.canProceed,
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(DesignSystem.Colors.background)
        .sheet(isPresented: $showAgePicker) {
            PickerSheet(
                title: "Select Age",
                selection: $state.age,
                range: 13...120,
                suffix: " years",
                isPresented: $showAgePicker
            )
        }
        .sheet(isPresented: $showHeightPicker) {
            if state.unitsPreference == .metric {
                PickerSheet(
                    title: "Select Height",
                    selection: $state.heightCm,
                    range: 100...250,
                    suffix: " cm",
                    isPresented: $showHeightPicker
                )
            } else {
                FeetInchesPickerSheet(
                    title: "Select Height",
                    feet: $state.heightFeet,
                    inches: $state.heightInches,
                    isPresented: $showHeightPicker
                )
            }
        }
        .sheet(isPresented: $showWeightPicker) {
            if state.unitsPreference == .metric {
                WeightPickerSheet(
                    title: "Select Weight",
                    weightKg: $state.weightKg,
                    isPresented: $showWeightPicker
                )
            } else {
                PickerSheet(
                    title: "Select Weight",
                    selection: Binding(
                        get: { Int(state.weightLbs) },
                        set: { state.weightLbs = Double($0) }
                    ),
                    range: 40...600,
                    suffix: " lbs",
                    isPresented: $showWeightPicker
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhysicalStatsView(state: OnboardingState())
    }
}
