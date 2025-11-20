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
                    .overlay(Color.borderPrimary)

                HStack {
                    if showBackButton {
                        Button {
                            HapticManager.shared.light()
                            onBack()
                        } label: {
                            Text("Back")
                                .font(DSTypography.headingMedium)
                                .foregroundColor(Color.textPrimary)
                                .underline()
                        }
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        onNext()
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Text(nextButtonText)
                                .font(DSTypography.buttonLarge)
                            Image(systemName: nextButtonIcon)
                                .font(DSTypography.buttonMedium)
                        }
                        .foregroundColor(Color.buttonPrimaryText)
                        .padding(.horizontal, DSSpacing.xl)
                        .frame(height: DSSize.buttonMedium)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.sm)
                                .fill(isNextEnabled ? Color.buttonPrimary : Color.textTertiary)
                        )
                    }
                    .disabled(!isNextEnabled)
                    .opacity(isNextEnabled ? 1.0 : 0.6)
                }
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.md)
                .background(Color.backgroundPrimary)
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
