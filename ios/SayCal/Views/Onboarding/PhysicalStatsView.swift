import SwiftUI

struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    OnboardingHeader(
                        title: "Your physical stats",
                        subtitle: "We'll use this to calculate your caloric needs"
                    )

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sex")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            
                            HStack(spacing: 12) {
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

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Age")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            Button {
                                HapticManager.shared.light()
                                showAgePicker.toggle()
                            } label: {
                                HStack {
                                    Text("\(state.age) years")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(UIColor.label))

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.Colors.background)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                                .cardShadow()
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Height")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            Button {
                                HapticManager.shared.light()
                                showHeightPicker.toggle()
                            } label: {
                                HStack {
                                    if state.unitsPreference == .metric {
                                        Text("\(state.heightCm) cm")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(UIColor.label))
                                    } else {
                                        Text("\(state.heightFeet)' \(state.heightInches)\"")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(UIColor.label))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.Colors.background)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                                .cardShadow()
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weight")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))

                            Button {
                                HapticManager.shared.light()
                                showWeightPicker.toggle()
                            } label: {
                                HStack {
                                    if state.unitsPreference == .metric {
                                        Text(String(format: "%.1f kg", state.weightKg))
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(UIColor.label))
                                    } else {
                                        Text("\(Int(state.weightLbs)) lbs")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(UIColor.label))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.Colors.background)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                                .cardShadow()
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }

            OnboardingBottomBar(
                isNextEnabled: state.canProceed,
                onBack: { state.previousStep() },
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
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
