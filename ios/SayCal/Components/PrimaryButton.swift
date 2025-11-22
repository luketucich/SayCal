import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    @State private var isPressed = false

    init(
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.medium()
            action()
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            } else {
                Text(title)
                    .font(DesignSystem.Typography.callout(weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
        }
        .background(
            Group {
                if isEnabled {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(
                            LinearGradient(
                                colors: DesignSystem.Colors.primaryGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(Color(UIColor.systemGray4))
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(isEnabled ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .opacity(isPressed ? 0.9 : 1.0)
        .animation(DesignSystem.Animations.quick, value: isPressed)
        .shadow(
            color: isEnabled ? DesignSystem.Colors.primary.opacity(0.3) : Color.clear,
            radius: 12,
            x: 0,
            y: 6
        )
        .disabled(!isEnabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.shared.medium()
            action()
        } label: {
            Text(title)
                .font(DesignSystem.Typography.callout(weight: .medium))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1.5)
                )
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(DesignSystem.Animations.quick, value: isPressed)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct TextButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Text(title)
                .font(DesignSystem.Typography.subheadline(weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.7 : 1.0)
        .animation(DesignSystem.Animations.fast, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Next", isEnabled: true, isLoading: false) {}
        PrimaryButton(title: "Next", isEnabled: false, isLoading: false) {}
        PrimaryButton(title: "Next", isEnabled: true, isLoading: true) {}
        SecondaryButton(title: "Reset") {}
        TextButton(title: "Skip") {}
    }
    .padding()
}
