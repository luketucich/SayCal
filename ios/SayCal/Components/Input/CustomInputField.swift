import SwiftUI

// Text field pill for adding custom preferences/allergies
struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void
    var onCancel: (() -> Void)? = nil

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 14))
            .foregroundColor(Color(UIColor.label))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: 160)
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Cancel") {
                        HapticManager.shared.light()
                        isFocused = false
                        text = ""
                        onCancel?()
                    }

                    Spacer()

                    Button("Add") {
                        HapticManager.shared.medium()
                        onSubmit()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
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
