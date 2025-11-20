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
                    .progressViewStyle(CircularProgressViewStyle(tint: DS.Colors.background))
                    .frame(maxWidth: .infinity)
                    .frame(height: DS.Layout.buttonHeightMedium)
            } else {
                Text(title)
                    .font(DS.Typography.callout(weight: .semibold))
                    .foregroundColor(isEnabled ? DS.Colors.background : DS.Colors.tertiaryLabel)
                    .frame(maxWidth: .infinity)
                    .frame(height: DS.Layout.buttonHeightMedium)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                .fill(isEnabled ? DS.Colors.label : DS.Colors.fill)
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
                .font(DS.Typography.callout(weight: .medium))
                .foregroundColor(DS.Colors.label)
                .frame(maxWidth: .infinity)
                .frame(height: DS.Layout.buttonHeightMedium)
        }
        .background(
            RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                .fill(DS.Colors.background)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                        .stroke(DS.Colors.separator, lineWidth: 1.5)
                )
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
                .font(DS.Typography.subheadline(weight: .regular))
                .foregroundColor(DS.Colors.label)
                .underline()
        }
    }
}

#Preview {
    VStack(spacing: DS.Spacing.medium) {
        PrimaryButton(title: "Next", isEnabled: true, isLoading: false) {}
        PrimaryButton(title: "Next", isEnabled: false, isLoading: false) {}
        PrimaryButton(title: "Next", isEnabled: true, isLoading: true) {}
        SecondaryButton(title: "Reset") {}
        TextButton(title: "Skip") {}
    }
    .padding(DS.Spacing.large)
    .background(DS.Colors.background)
}
