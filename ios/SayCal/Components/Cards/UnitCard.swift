import SwiftUI

struct UnitCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.medium) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(DesignSystem.Typography.titleMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text(subtitle)
                        .font(DesignSystem.Typography.captionLarge)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()

                Circle()
                    .strokeBorder(
                        isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.borderMedium,
                        lineWidth: DesignSystem.BorderWidth.thick
                    )
                    .background(
                        Circle().fill(isSelected ? DesignSystem.Colors.primary : Color.clear)
                    )
                    .frame(
                        width: DesignSystem.Dimensions.selectionIndicatorSize,
                        height: DesignSystem.Dimensions.selectionIndicatorSize
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: DesignSystem.Dimensions.selectionCheckmarkSize, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                            }
                        }
                    )
            }
            .cardPadding()
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Colors.cardBackground)
                    .applyShadow(isSelected ? DesignSystem.Shadow.medium : DesignSystem.Shadow.light)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        UnitCard(
            title: "Metric",
            subtitle: "Kilograms • Centimeters",
            isSelected: true
        ) {}

        UnitCard(
            title: "Imperial",
            subtitle: "Pounds • Feet & Inches",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
