import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.xxLarge) {
                    OnboardingHeader(
                        title: "Your physical stats",
                        subtitle: "We'll use this to calculate your caloric needs"
                    )

                    VStack(spacing: DS.Spacing.large) {
                        VStack(alignment: .leading, spacing: DS.Spacing.xSmall) {
                            Text("Sex")
                                .font(DS.Typography.footnote(weight: .medium))
                                .foregroundColor(DS.Colors.secondaryLabel)

                            HStack(spacing: DS.Spacing.small) {
                                TogglePill(
                                    title: "Male",
                                    isSelected: state.sex == .male,
                                    style: .rounded
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        state.sex = .male
                                    }
                                }

                                TogglePill(
                                    title: "Female",
                                    isSelected: state.sex == .female,
                                    style: .rounded
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        state.sex = .female
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: DS.Spacing.xSmall) {
                            Text("Age")
                                .font(DS.Typography.footnote(weight: .medium))
                                .foregroundColor(DS.Colors.secondaryLabel)

                            Button {
                                HapticManager.shared.light()
                                showAgePicker.toggle()
                            } label: {
                                HStack(spacing: DS.Spacing.medium) {
                                    Text("\(state.age) years")
                                        .font(DS.Typography.callout())
                                        .foregroundColor(DS.Colors.label)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(DS.Typography.footnote())
                                        .foregroundColor(DS.Colors.tertiaryLabel)
                                }
                                .padding(.horizontal, DS.Spacing.medium)
                                .padding(.vertical, DS.Spacing.small)
                                .background(
                                    RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                                        .fill(DS.Colors.background)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                                                .stroke(DS.Colors.separator, lineWidth: 1)
                                        )
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: DS.Spacing.xSmall) {
                            Text("Height")
                                .font(DS.Typography.footnote(weight: .medium))
                                .foregroundColor(DS.Colors.secondaryLabel)

                            Button {
                                HapticManager.shared.light()
                                showHeightPicker.toggle()
                            } label: {
                                HStack(spacing: DS.Spacing.medium) {
                                    if state.unitsPreference == .metric {
                                        Text("\(state.heightCm) cm")
                                            .font(DS.Typography.callout())
                                            .foregroundColor(DS.Colors.label)
                                    } else {
                                        Text("\(state.heightFeet)' \(state.heightInches)\"")
                                            .font(DS.Typography.callout())
                                            .foregroundColor(DS.Colors.label)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(DS.Typography.footnote())
                                        .foregroundColor(DS.Colors.tertiaryLabel)
                                }
                                .padding(.horizontal, DS.Spacing.medium)
                                .padding(.vertical, DS.Spacing.small)
                                .background(
                                    RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                                        .fill(DS.Colors.background)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                                                .stroke(DS.Colors.separator, lineWidth: 1)
                                        )
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: DS.Spacing.xSmall) {
                            Text("Weight")
                                .font(DS.Typography.footnote(weight: .medium))
                                .foregroundColor(DS.Colors.secondaryLabel)

                            Button {
                                HapticManager.shared.light()
                                showWeightPicker.toggle()
                            } label: {
                                HStack(spacing: DS.Spacing.medium) {
                                    if state.unitsPreference == .metric {
                                        Text(String(format: "%.1f kg", state.weightKg))
                                            .font(DS.Typography.callout())
                                            .foregroundColor(DS.Colors.label)
                                    } else {
                                        Text("\(Int(state.weightLbs)) lbs")
                                            .font(DS.Typography.callout())
                                            .foregroundColor(DS.Colors.label)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(DS.Typography.footnote())
                                        .foregroundColor(DS.Colors.tertiaryLabel)
                                }
                                .padding(.horizontal, DS.Spacing.medium)
                                .padding(.vertical, DS.Spacing.small)
                                .background(
                                    RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                                        .fill(DS.Colors.background)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                                                .stroke(DS.Colors.separator, lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DS.Layout.screenPadding)
            }

            OnboardingBottomBar(
                isNextEnabled: state.canProceed,
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(DS.Colors.background)
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
