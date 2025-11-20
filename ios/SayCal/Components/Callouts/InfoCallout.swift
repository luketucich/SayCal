import SwiftUI

struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: DS.Spacing.xSmall) {
            Image(systemName: "info.circle")
                .font(DS.Typography.footnote())
                .foregroundColor(DS.Colors.tertiaryLabel)

            Text(message)
                .font(DS.Typography.footnote())
                .foregroundColor(DS.Colors.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                .fill(DS.Colors.tertiaryBackground)
        )
    }
}

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding(DS.Spacing.large)
        .background(DS.Colors.background)
}
