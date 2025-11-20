import SwiftUI

struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.xs) {
            Image(systemName: "info.circle")
                .font(DSTypography.labelMedium)
                .foregroundColor(Color.primaryBlue)

            Text(message)
                .font(DSTypography.captionLarge)
                .foregroundColor(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(Color.backgroundTertiary)
        )
    }
}

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding()
        .background(Color(UIColor.systemBackground))
}
