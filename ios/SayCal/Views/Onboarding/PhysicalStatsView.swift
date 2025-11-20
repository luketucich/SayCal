import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xxl) {
                    OnboardingHeader(
                        title: "Your physical stats",
                        subtitle: "We'll use this to calculate your caloric needs"
                    )

                    VStack(spacing: DSSpacing.lg) {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Sex")
                                .font(DSTypography.labelMedium)
                                .foregroundColor(Color.textSecondary)

                            HStack(spacing: DSSpacing.sm) {
                                TogglePill(
                                    title: "Male",
                                    isSelected: state.sex == .male,
                                    style: .rounded
                                ) {
                                    withAnimation(DSAnimation.quick) {
                                        state.sex = .male
                                    }
                                }

                                TogglePill(
                                    title: "Female",
                                    isSelected: state.sex == .female,
                                    style: .rounded
                                ) {
                                    withAnimation(DSAnimation.quick) {
                                        state.sex = .female
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Age")
                                .font(DSTypography.labelMedium)
                                .foregroundColor(Color.textSecondary)

                            Button {
                                HapticManager.shared.light()
                                showAgePicker.toggle()
                            } label: {
                                HStack {
                                    Text("\(state.age) years")
                                        .font(DSTypography.bodyMedium)
                                        .foregroundColor(Color.textPrimary)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(DSTypography.labelMedium)
                                        .foregroundColor(Color.textTertiary)
                                }
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Height")
                                .font(DSTypography.labelMedium)
                                .foregroundColor(Color.textSecondary)

                            Button {
                                HapticManager.shared.light()
                                showHeightPicker.toggle()
                            } label: {
                                HStack {
                                    if state.unitsPreference == .metric {
                                        Text("\(state.heightCm) cm")
                                            .font(DSTypography.bodyMedium)
                                            .foregroundColor(Color.textPrimary)
                                    } else {
                                        Text("\(state.heightFeet)' \(state.heightInches)\"")
                                            .font(DSTypography.bodyMedium)
                                            .foregroundColor(Color.textPrimary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(DSTypography.labelMedium)
                                        .foregroundColor(Color.textTertiary)
                                }
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Weight")
                                .font(DSTypography.labelMedium)
                                .foregroundColor(Color.textSecondary)

                            Button {
                                HapticManager.shared.light()
                                showWeightPicker.toggle()
                            } label: {
                                HStack {
                                    if state.unitsPreference == .metric {
                                        Text(String(format: "%.1f kg", state.weightKg))
                                            .font(DSTypography.bodyMedium)
                                            .foregroundColor(Color.textPrimary)
                                    } else {
                                        Text("\(Int(state.weightLbs)) lbs")
                                            .font(DSTypography.bodyMedium)
                                            .foregroundColor(Color.textPrimary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(DSTypography.labelMedium)
                                        .foregroundColor(Color.textTertiary)
                                }
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DSSpacing.lg)
            }

            OnboardingBottomBar(
                isNextEnabled: state.canProceed,
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color.backgroundPrimary)
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
