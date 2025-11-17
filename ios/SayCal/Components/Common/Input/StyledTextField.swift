import SwiftUI

/// Styled text field with capsule design for consistent input across the app
struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 14))
            .foregroundColor(Color(UIColor.label))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        Capsule()
                            .stroke(Color(UIColor.label), lineWidth: 1.5)
                    )
            )
            .focused($isFocused)
            .onSubmit(onSubmit)
    }
}

// Alias for backward compatibility with onboarding
typealias CustomInputField = StyledTextField

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            StyledTextField(
                placeholder: "Enter text",
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
