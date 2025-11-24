import SwiftUI

enum InputMethod {
    case voice
    case text
}

struct PlusButton: View {
    @Binding var selectedMethod: InputMethod?
    @State private var isPressed = false
    @State private var showOptions = false
    @State private var longPressTimer: Timer?

    var body: some View {
        ZStack {
            // Options menu (shown when held)
            if showOptions {
                HStack(spacing: 20) {
                    // Microphone option
                    Button {
                        HapticManager.shared.medium()
                        withAnimation(.spring(response: 0.3)) {
                            selectedMethod = .voice
                            showOptions = false
                        }
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))

                    // Keyboard option
                    Button {
                        HapticManager.shared.medium()
                        withAnimation(.spring(response: 0.3)) {
                            selectedMethod = .text
                            showOptions = false
                        }
                    } label: {
                        Image(systemName: "keyboard.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.green)
                            )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                .padding(.horizontal, 8)
            }

            // Main plus button
            if !showOptions {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.9), Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .blue.opacity(0.35), radius: 12, y: 6)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                                HapticManager.shared.medium()
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3)) {
                                showOptions = true
                                isPressed = false
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            isPressed = false
                        }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showOptions)
        .onChange(of: selectedMethod) { _, newValue in
            if newValue != nil {
                showOptions = false
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        PlusButton(selectedMethod: .constant(nil))
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
}
