import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        TextField(placeholder, text: $text)
            .font(DSTypography.labelMedium)
            .foregroundColor(Color.textPrimary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .frame(maxWidth: 160)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
                    .overlay(
                        Capsule()
                            .stroke(isFocused ? Color.primaryBlue : Color.borderPrimary, lineWidth: isFocused ? DSBorder.thick : DSBorder.medium)
                    )
            )
            .focused($isFocused)
            .onSubmit(onSubmit)
            .animation(DSAnimation.quick, value: isFocused)
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
