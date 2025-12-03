import SwiftUI

struct MealInputToolbar: View {
    @Binding var textInput: String
    @FocusState.Binding var isTextInputFocused: Bool
    let onCancel: () -> Void
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Text input field
            TextField("What did you eat?", text: $textInput, axis: .vertical)
                .focused($isTextInputFocused)
                .lineLimit(1...10)
                .submitLabel(.send)
                .onSubmit {
                    if !textInput.isEmpty { onSend() }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.primary.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .fixedSize(horizontal: false, vertical: true)

            // Cancel button
            Button {
                HapticManager.shared.light()
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)

            // Send button
            Button {
                HapticManager.shared.medium()
                onSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(textInput.isEmpty ? .secondary : .primary)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)
            .disabled(textInput.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
