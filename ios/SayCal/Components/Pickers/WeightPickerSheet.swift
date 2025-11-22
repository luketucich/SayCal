import SwiftUI

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
                        HapticManager.shared.medium()
                        isPresented = false
                    }
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.primaryText)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var weightKg = 70.0
        @State private var showWeightPicker = true

        var body: some View {
            VStack {
                Text("Weight Picker")
            }
            .sheet(isPresented: $showWeightPicker) {
                WeightPickerSheet(
                    title: "Select Weight",
                    weightKg: $weightKg,
                    isPresented: $showWeightPicker
                )
            }
        }
    }

    return PreviewWrapper()
}
