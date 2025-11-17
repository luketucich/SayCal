import SwiftUI

// MARK: - Generic Picker Sheet
/// A generic picker sheet for selecting a single value from a range
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
                    .foregroundColor(Color(UIColor.label))
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Feet & Inches Picker Sheet
/// Picker sheet for selecting height in feet and inches
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

// MARK: - Weight Picker Sheet (Metric)
/// Picker sheet for selecting weight in kilograms with decimal precision
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
    struct PreviewWrapper: View {
        @State private var age = 25
        @State private var showAgePicker = true
        @State private var feet = 5
        @State private var inches = 10
        @State private var showHeightPicker = false
        @State private var weightKg = 70.0
        @State private var showWeightPicker = false

        var body: some View {
            VStack {
                Text("Picker Previews")
            }
            .sheet(isPresented: $showAgePicker) {
                PickerSheet(
                    title: "Select Age",
                    selection: $age,
                    range: 13...120,
                    suffix: " years",
                    isPresented: $showAgePicker
                )
            }
        }
    }

    return PreviewWrapper()
}
