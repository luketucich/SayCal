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
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(uiColor: .systemBackground)))
                    .frame(maxWidth: .infinity)
                    .frame(height: Dimensions.buttonHeightLarge)
            } else {
                Text(title)
                    .font(.bodyMedium)
                    .foregroundColor(isEnabled ? Color(uiColor: .systemBackground) : .textDisabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: Dimensions.buttonHeightLarge)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.pill)
                .fill(isEnabled ? Color.textPrimary : .border)
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
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: Dimensions.buttonHeightLarge)
        }
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.pill)
                .stroke(Color.textPrimary, lineWidth: LineWidth.regular)
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
                .font(.caption)
                .foregroundColor(.textSecondary)
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
