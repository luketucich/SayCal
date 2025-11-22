import SwiftUI

struct FormPickerButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(DesignSystem.Typography.bodyLarge)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: DesignSystem.Dimensions.iconSmall, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.componentSpacing)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.cardBackground)
                    .lightShadow()
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .strokeBorder(DesignSystem.Colors.borderLight, lineWidth: DesignSystem.BorderWidth.medium)
                    )
            )
        }
    }
}
