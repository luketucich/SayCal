import SwiftUI

struct OnboardingBottomBar: View {
    let showBackButton: Bool
    let nextButtonText: String
    let nextButtonIcon: String
    let isNextEnabled: Bool
    let hideWhenFocused: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    init(
        showBackButton: Bool = true,
        nextButtonText: String = "Next",
        nextButtonIcon: String = "arrow.right",
        isNextEnabled: Bool = true,
        hideWhenFocused: Bool = false,
        onBack: @escaping () -> Void = {},
        onNext: @escaping () -> Void
    ) {
        self.showBackButton = showBackButton
        self.nextButtonText = nextButtonText
        self.nextButtonIcon = nextButtonIcon
        self.isNextEnabled = isNextEnabled
        self.hideWhenFocused = hideWhenFocused
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        if !hideWhenFocused {
            VStack(spacing: 0) {
                Divider()
                    .overlay(Theme.Colors.borderLight)

                HStack {
                    if showBackButton {
                        Button {
                            HapticManager.shared.light()
                            onBack()
                        } label: {
                            Text("Back")
                                .font(Theme.Typography.body)
                                .fontWeight(.medium)
                                .foregroundColor(Theme.Colors.secondaryLabel)
                                .underline()
                        }
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        onNext()
                    } label: {
                        HStack(spacing: Theme.Spacing.xxs) {
                            Text(nextButtonText)
                                .font(Theme.Typography.headline)
                            Image(systemName: nextButtonIcon)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, Theme.Spacing.xl)
                        .frame(height: Theme.ButtonSize.standard)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .fill(isNextEnabled ? Theme.Colors.accent : Theme.Colors.accent.opacity(0.5))
                        )
                        .mediumShadow()
                        .opacity(isNextEnabled ? 1.0 : 0.6)
                    }
                    .disabled(!isNextEnabled)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.background)
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        OnboardingBottomBar(
            onBack: {},
            onNext: {}
        )
    }
    .background(Color(UIColor.systemBackground))
}
