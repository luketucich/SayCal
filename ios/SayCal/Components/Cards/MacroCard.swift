import SwiftUI

struct MacroCard: View {
    let title: String
    let percentage: Int
    let color: Color
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.Colors.secondaryLabel)

            Text("\(percentage)%")
                .font(Theme.Typography.number(size: 24, weight: .bold))
                .foregroundColor(color)

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(color.opacity(0.1))
        )
        .cardShadow()
    }
}
