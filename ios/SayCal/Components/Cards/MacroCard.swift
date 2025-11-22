import SwiftUI

struct MacroCard: View {
    let title: String
    let percentage: Int
    let color: Color
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.system(size: DesignTokens.FontSize.small, weight: .medium))
                .foregroundColor(Color(UIColor.secondaryLabel))

            Text("\(percentage)%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                .fill(color.opacity(DesignTokens.Opacity.veryLight))
        )
    }
}
