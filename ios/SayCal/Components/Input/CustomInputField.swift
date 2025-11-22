import SwiftUI

struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void


    var body: some View {
        TextField(placeholder, text: $text)
            .font(DesignSystem.Typography.bodySmall)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .frame(maxWidth: 160)
            .background(
                Capsule()
                    .fill(DesignSystem.Colors.cardBackground)
                    .lightShadow()
                    .overlay(
                        Capsule()
                            .strokeBorder(DesignSystem.Colors.borderMedium, lineWidth: DesignSystem.BorderWidth.medium)
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
