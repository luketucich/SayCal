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
            action()
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            } else {
                Text(title)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .background(isEnabled ? Color.accentColor : Color.gray)
        .cornerRadius(32)
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue", isEnabled: true, isLoading: false) {}
        PrimaryButton(title: "Continue", isEnabled: false, isLoading: false) {}
        PrimaryButton(title: "Continue", isEnabled: true, isLoading: true) {}
    }
    .padding()
}
