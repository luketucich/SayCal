import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void


    var body: some View {
        TextField(placeholder, text: $text)
            .font(.caption)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: 160)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
                    .overlay(
                        Capsule()
                            .stroke(Color.textPrimary, lineWidth: LineWidth.regular)
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
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }

    return PreviewWrapper()
}
