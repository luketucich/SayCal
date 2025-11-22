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
                    .overlay(DesignSystem.Colors.borderLight)

                HStack {
                    if showBackButton {
                        Button {
                            HapticManager.shared.light()
                            onBack()
                        } label: {
                            Text("Back")
                                .font(DesignSystem.Typography.labelMedium)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        onNext()
                    } label: {
                        HStack(spacing: 6) {
                            Text(nextButtonText)
                                .font(DesignSystem.Typography.buttonLarge)
                            Image(systemName: nextButtonIcon)
                                .font(.system(size: DesignSystem.Dimensions.iconSmall, weight: .semibold))
                        }
                        .foregroundColor(isNextEnabled ? DesignSystem.Colors.primaryText : DesignSystem.Colors.textSecondary)
                        .padding(.horizontal, DesignSystem.Spacing.xxlarge)
                        .frame(height: DesignSystem.Dimensions.buttonHeightMedium)
                        .background(
                            Capsule()
                                .fill(isNextEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.borderLight)
                        )
                    }
                    .disabled(!isNextEnabled)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenEdge)
                .padding(.vertical, DesignSystem.Spacing.large)
                .background(DesignSystem.Colors.cardBackground)
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
