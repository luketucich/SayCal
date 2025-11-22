import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

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
                    .frame(height: Theme.ButtonSize.standard)
            } else {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.ButtonSize.standard)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(isEnabled ? Theme.Colors.accent : Theme.Colors.accent.opacity(0.5))
        )
        .mediumShadow()
        .opacity(isEnabled ? 1.0 : 0.6)
        .disabled(!isEnabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.medium()
            action()
        } label: {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.ButtonSize.standard)
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.standard)
        )
        .cardShadow()
    }
}

struct TextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Text(title)
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryLabel)
                .underline()
        }
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
