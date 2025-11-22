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
                    .overlay(Color.border)

                HStack {
                    if showBackButton {
                        Button {
                            HapticManager.shared.light()
                            onBack()
                        } label: {
                            Text("Back")
                                .font(.captionMedium)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        HapticManager.shared.medium()
                        onNext()
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Text(nextButtonText)
                                .font(.bodyMedium)
                            Image(systemName: nextButtonIcon)
                                .font(.iconSemibold)
                        }
                        .foregroundColor(isNextEnabled ? Color(uiColor: .systemBackground) : .textDisabled)
                        .padding(.horizontal, Spacing.xxl)
                        .frame(height: Dimensions.buttonHeightLarge)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.pill)
                                .fill(isNextEnabled ? Color.textPrimary : .borderSubtle)
                        )
                    }
                    .disabled(!isNextEnabled)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.cardBackground)
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
