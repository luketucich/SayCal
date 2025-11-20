import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        TextField(placeholder, text: $text)
            .font(DS.Typography.footnote())
            .foregroundColor(DS.Colors.label)
            .padding(.horizontal, DS.Spacing.small)
            .padding(.vertical, DS.Spacing.xSmall)
            .frame(maxWidth: 160)
            .background(
                Capsule()
                    .fill(DS.Colors.background)
                    .overlay(
                        Capsule()
                            .stroke(DS.Colors.label, lineWidth: 1.5)
                    )
            )
            .focused($isFocused)
            .onSubmit(onSubmit)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            CustomInputField(
                placeholder: "Enter preference",
                text: $text,
                isFocused: $isFocused,
                onSubmit: {}
            )
            .padding(DS.Spacing.large)
            .background(DS.Colors.background)
        }
    }

    return PreviewWrapper()
}
