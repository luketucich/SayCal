import SwiftUI

struct TogglePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let style: PillStyle

    enum PillStyle {
        case capsule        // preferences and allergies
        case rounded        // gender selection
    }

    init(
        title: String,
        isSelected: Bool,
        style: PillStyle = .capsule,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            Group {
                if style == .capsule {
                    capsuleContent
                } else {
                    roundedContent
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var capsuleContent: some View {
        HStack(spacing: 6) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }

            Text(title)
                .font(DesignSystem.Typography.bodySmall)
                .foregroundColor(isSelected ? DesignSystem.Colors.primaryText : DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.xlarge)
        .padding(.vertical, DesignSystem.Spacing.medium)
        .background(
            Capsule()
                .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.cardBackground)
                .lightShadow()
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color.clear : DesignSystem.Colors.borderLight,
                            lineWidth: DesignSystem.BorderWidth.medium
                        )
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(DesignSystem.Typography.labelLarge)
            .foregroundColor(isSelected ? DesignSystem.Colors.primaryText : DesignSystem.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Dimensions.buttonHeightMedium)
            .background(
                Capsule()
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.cardBackground)
                    .lightShadow()
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                isSelected ? Color.clear : DesignSystem.Colors.borderLight,
                                lineWidth: DesignSystem.BorderWidth.medium
                            )
                    )
            )
    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 8) {
            TogglePill(title: "Vegan", isSelected: true) {}
            TogglePill(title: "Gluten-free", isSelected: false) {}
        }

        HStack(spacing: 12) {
            TogglePill(title: "Male", isSelected: true, style: .rounded) {}
            TogglePill(title: "Female", isSelected: false, style: .rounded) {}
        }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
