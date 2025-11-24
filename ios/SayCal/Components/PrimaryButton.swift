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
                    .frame(height: 48)
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isEnabled ? Color.blue : Color.blue.opacity(0.5))
        )
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
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1.5)
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
                .font(.callout)
                .foregroundStyle(.secondary)
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
