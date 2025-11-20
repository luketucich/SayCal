import SwiftUI

struct FormPickerButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(DSTypography.bodyLarge)
                    .foregroundColor(Color.textPrimary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(DSTypography.bodySmall)
                    .foregroundColor(Color.textTertiary)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
