import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    OnboardingHeader(
                        title: "Your physical stats",
                        subtitle: "We'll use this to calculate your caloric needs"
                    )

                    VStack(spacing: Spacing.lg) {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Sex")
                                .font(.smallCaptionMedium)
                                .foregroundColor(.textSecondary)

                            HStack(spacing: Spacing.sm) {
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

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Age")
                                .font(.smallCaptionMedium)
                                .foregroundColor(.textSecondary)

                            Button {
                                HapticManager.shared.light()
                                showAgePicker.toggle()
                            } label: {
                                HStack {
                                    Text("\(state.age) years")
                                        .font(.bodyMedium)
                                        .foregroundColor(.textPrimary)

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .fill(Color(UIColor.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                                .stroke(Color(UIColor.systemGray5), lineWidth: 1.5)
                                        )
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Height")
                                .font(.smallCaptionMedium)
                                .foregroundColor(.textSecondary)

                            Button {
                                HapticManager.shared.light()
                                showHeightPicker.toggle()
                            } label: {
                                HStack {
                                    if state.unitsPreference == .metric {
                                        Text("\(state.heightCm) cm")
                                            .font(.bodyMedium)
                                            .foregroundColor(.textPrimary)
                                    } else {
                                        Text("\(state.heightFeet)' \(state.heightInches)\"")
                                            .font(.bodyMedium)
                                            .foregroundColor(.textPrimary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .fill(Color(UIColor.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                                .stroke(Color(UIColor.systemGray5), lineWidth: 1.5)
                                        )
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Weight")
                                .font(.smallCaptionMedium)
                                .foregroundColor(.textSecondary)

                            Button {
                                HapticManager.shared.light()
                                showWeightPicker.toggle()
                            } label: {
                                HStack {
                                    if state.unitsPreference == .metric {
                                        Text(String(format: "%.1f kg", state.weightKg))
                                            .font(.bodyMedium)
                                            .foregroundColor(.textPrimary)
                                    } else {
                                        Text("\(Int(state.weightLbs)) lbs")
                                            .font(.bodyMedium)
                                            .foregroundColor(.textPrimary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.textSecondary)
                                }
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.md)
                                        .fill(Color(UIColor.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                                .stroke(Color(UIColor.systemGray5), lineWidth: 1.5)
                                        )
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Spacing.lg)
            }

            OnboardingBottomBar(
                isNextEnabled: state.canProceed,
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color.appBackground)
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
