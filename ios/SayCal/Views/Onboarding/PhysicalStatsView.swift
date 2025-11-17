import SwiftUI

/// Step 2: Physical stats collection
struct PhysicalStatsView: View {
    @ObservedObject var state: OnboardingState
    @State private var showAgePicker = false
    @State private var showHeightPicker = false
    @State private var showWeightPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your physical stats")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        Text("We'll use this to calculate your caloric needs")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.top, 24)
                    
                    // Stats input sections
                    VStack(spacing: 20) {
                        // Sex selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sex")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            
                            HStack(spacing: 12) {
                                GenderPill(
                                    title: "Male",
                                    isSelected: state.sex == .male
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        state.sex = .male
                                    }
                                }
                                
                                GenderPill(
                                    title: "Female",
                                    isSelected: state.sex == .female
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        state.sex = .female
                                    }
                                }
                            }
                        }
                        
                        // Age selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Age")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            
                            Button {
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
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Height selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Height")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            
                            Button {
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
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Weight selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weight")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            
                            Button {
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
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom button area
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color(UIColor.systemGray5))
                
                HStack {
                    Button {
                        state.previousStep()
                    } label: {
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(UIColor.label))
                            .underline()
                    }
                    
                    Spacer()
                    
                    Button {
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(state.canProceed ? Color(UIColor.label) : Color(UIColor.systemGray4))
                        )
                    }
                    .disabled(!state.canProceed)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
            }
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
                    range: 44...440,
                    suffix: " lbs",
                    isPresented: $showWeightPicker
                )
            }
        }
    }
}

// Gender selection pill
struct GenderPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(UIColor.label))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// Clean picker sheet
struct PickerSheet: View {
    let title: String
    @Binding var selection: Int
    let range: ClosedRange<Int>
    let suffix: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selection) {
                    ForEach(range, id: \.self) { value in
                        Text("\(value)\(suffix)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// Feet and inches picker sheet
struct FeetInchesPickerSheet: View {
    let title: String
    @Binding var feet: Int
    @Binding var inches: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                Picker("Feet", selection: $feet) {
                    ForEach(4..<8, id: \.self) { ft in
                        Text("\(ft) ft").tag(ft)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Inches", selection: $inches) {
                    ForEach(0..<12, id: \.self) { inch in
                        Text("\(inch) in").tag(inch)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 200)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// Weight picker sheet for kg with decimals
struct WeightPickerSheet: View {
    let title: String
    @Binding var weightKg: Double
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Picker("", selection: Binding(
                get: { Int(weightKg * 2) },
                set: { weightKg = Double($0) / 2.0 }
            )) {
                ForEach(40...400, id: \.self) { halfKg in
                    let kg = Double(halfKg) / 2.0
                    Text(String(format: "%.1f kg", kg)).tag(halfKg)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 200)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(UIColor.label))
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

#Preview {
    NavigationStack {
        PhysicalStatsView(state: OnboardingState())
    }
}
