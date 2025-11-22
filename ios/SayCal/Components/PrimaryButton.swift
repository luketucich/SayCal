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
                    .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primaryText))
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.Dimensions.buttonHeightLarge)
            } else {
                Text(title)
                    .font(DesignSystem.Typography.buttonLarge)
                    .foregroundColor(isEnabled ? DesignSystem.Colors.primaryText : DesignSystem.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignSystem.Dimensions.buttonHeightLarge)
            }
        }
        .background(
            Capsule()
                .fill(isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.borderLight)
        )
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
                .font(DesignSystem.Typography.buttonLarge)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.Dimensions.buttonHeightLarge)
        }
        .background(
            Capsule()
                .strokeBorder(DesignSystem.Colors.borderMedium, lineWidth: DesignSystem.BorderWidth.medium)
                .background(Capsule().fill(DesignSystem.Colors.cardBackground))
                .lightShadow()
        )
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
                .font(DesignSystem.Typography.labelMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
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
