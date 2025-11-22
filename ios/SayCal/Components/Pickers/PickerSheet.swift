import SwiftUI

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
        @State private var age = 25
        @State private var showAgePicker = true

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
