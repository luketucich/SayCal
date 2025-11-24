import SwiftUI

struct TextInputOverlay: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    var onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Text input
            TextField("Input your meal", text: $text)
                .focused($isFocused)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                )

            // Send button
            Button {
                HapticManager.shared.medium()
                onSend()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(text.isEmpty ? Color.gray : Color.blue)
                    )
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        TextInputOverlay(
            text: .constant(""),
            isPresented: .constant(true),
            onSend: {}
        )
    }
    .background(Color(.systemGray6))
}
