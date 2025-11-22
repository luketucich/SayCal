import SwiftUI

struct FormPickerButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.label)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Theme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.borderLight, lineWidth: Theme.BorderWidth.thin)
            )
            .cardShadow()
        }
    }
}
