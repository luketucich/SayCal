import SwiftUI

struct FormPickerButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.medium) {
                Text(label)
                    .font(DS.Typography.callout())
                    .foregroundColor(DS.Colors.label)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(DS.Typography.footnote())
                    .foregroundColor(DS.Colors.tertiaryLabel)
            }
            .padding(.horizontal, DS.Spacing.medium)
            .padding(.vertical, DS.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                    .fill(DS.Colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                            .stroke(DS.Colors.separator, lineWidth: 1)
                    )
            )
        }
    }
}
