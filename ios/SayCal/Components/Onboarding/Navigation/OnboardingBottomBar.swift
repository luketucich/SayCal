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
                    .overlay(Color(UIColor.systemGray5))

                HStack {
                    if showBackButton {
                        Button {
                            HapticManager.shared.light()
                            onBack()
                        } label: {
                            Text("Back")
                                .font(AppTypography.captionMedium)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        onNext()
                    } label: {
                        HStack(spacing: 6) {
                            Text(nextButtonText)
                                .font(AppTypography.bodyMedium)
                            Image(systemName: nextButtonIcon)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(isNextEnabled ? Color(UIColor.systemBackground) : Color(UIColor.secondaryLabel))
                        .padding(.horizontal, AppSpacing.xl)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.pill)
                                .fill(isNextEnabled ? AppColors.primaryText : Color(UIColor.systemGray4))
                        )
                    }
                    .disabled(!isNextEnabled)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(Color(UIColor.systemBackground))
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
