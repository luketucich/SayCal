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
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemBackground)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            } else {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(isEnabled ? Color(UIColor.systemBackground) : Color(UIColor.systemGray3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.pill)
                .fill(isEnabled ? Color(UIColor.label) : Color(UIColor.systemGray5))
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
                .font(AppTypography.bodyMedium)
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
        }
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.pill)
                .stroke(Color(UIColor.label), lineWidth: 1.5)
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
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
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
