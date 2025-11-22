import SwiftUI

struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.xs) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.accent)

            Text(message)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.accentLight)
        )
        .cardShadow()
    }
}

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding()
        .background(Color(UIColor.systemBackground))
}
