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
                .fixedSize(horizontal: false, vertical: true)

            // Cancel button
            Button {
                HapticManager.shared.light()
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.appCardBackground, in: Circle())
                    .cardShadow()
            }
            .buttonStyle(.plain)

            // Send button
            Button {
                HapticManager.shared.medium()
                onSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(textInput.isEmpty ? .secondary : .primary)
                    .frame(width: 36, height: 36)
                    .background(Color.appCardBackground, in: Circle())
                    .cardShadow()
            }
            .buttonStyle(.plain)
            .disabled(textInput.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.top, 4)
        .background(
            Color.appBackground
                // Extend under the keyboard only, so the fade is at the toolbar's top edge.
                // If you want the fade at the very top of the screen instead, change to `.all`.
                .ignoresSafeArea(edges: .bottom)
                // Fade only the background at the very top
                .mask(
                    VStack(spacing: 0) {
                        // Adjust this to control the fade length
                        LinearGradient(colors: [.clear, .black],
                                       startPoint: .top,
                                       endPoint: .bottom)
                            .frame(height: 12)
                        Color.black
                    }
                )
        )
    }
}
