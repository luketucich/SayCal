import SwiftUI

struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "info.circle")
                .font(.system(size: DesignSystem.Dimensions.iconSmall))
                .foregroundColor(DesignSystem.Colors.textTertiary)

            Text(message)
                .font(DesignSystem.Typography.captionLarge)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.large)
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

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding()
        .background(Color(UIColor.systemBackground))
}
