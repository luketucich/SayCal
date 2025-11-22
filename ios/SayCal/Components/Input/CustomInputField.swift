import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void


    var body: some View {
        TextField(placeholder, text: $text)
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.label)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs + 2)
            .frame(maxWidth: 160)
            .background(
                Capsule()
                    .fill(Theme.Colors.background)
            )
            .overlay(
                Capsule()
                    .stroke(Theme.Colors.accent, lineWidth: Theme.BorderWidth.standard)
            )
            .cardShadow()
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
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }

    return PreviewWrapper()
}
