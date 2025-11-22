import SwiftUI

struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
            Image(systemName: "info.circle")
                .font(.system(size: DesignTokens.FontSize.label))
                .foregroundColor(Color(UIColor.tertiaryLabel))

            Text(message)
                .font(.system(size: DesignTokens.FontSize.small))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding()
        .background(Color(UIColor.systemBackground))
}
