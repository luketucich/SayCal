import SwiftUI

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
                        HapticManager.shared.medium()
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
        @State private var feet = 5
        @State private var inches = 10
        @State private var showHeightPicker = true

        var body: some View {
            VStack {
                Text("Height Picker")
            }
            .sheet(isPresented: $showHeightPicker) {
                FeetInchesPickerSheet(
                    title: "Select Height",
                    feet: $feet,
                    inches: $inches,
                    isPresented: $showHeightPicker
                )
            }
        }
    }

    return PreviewWrapper()
}
