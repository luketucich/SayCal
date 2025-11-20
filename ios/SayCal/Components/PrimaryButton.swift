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
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.buttonPrimaryText))
                    .frame(maxWidth: .infinity)
                    .frame(height: DSSize.buttonLarge)
            } else {
                Text(title)
                    .font(DSTypography.buttonLarge)
                    .foregroundColor(Color.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: DSSize.buttonLarge)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(isEnabled ? Color.buttonPrimary : Color.textTertiary)
        )
        .opacity(isEnabled ? 1.0 : 0.6)
        .disabled(!isEnabled || isLoading)
        .animation(DSAnimation.quick, value: isEnabled)
    }
}

struct SecondaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    init(
        title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.medium()
            action()
        } label: {
            Text(title)
                .font(DSTypography.buttonLarge)
                .foregroundColor(Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: DSSize.buttonLarge)
        }
        .background(Color.buttonSecondary)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(Color.buttonSecondaryBorder, lineWidth: DSBorder.medium)
        )
        .cornerRadius(DSRadius.md)
        .opacity(isEnabled ? 1.0 : 0.6)
        .disabled(!isEnabled)
        .animation(DSAnimation.quick, value: isEnabled)
    }
}

struct TextButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    init(
        title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Text(title)
                .font(DSTypography.bodyMedium)
                .foregroundColor(Color.textPrimary)
                .underline()
        }
        .opacity(isEnabled ? 1.0 : 0.6)
        .disabled(!isEnabled)
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
