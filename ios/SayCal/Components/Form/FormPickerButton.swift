import SwiftUI

struct FormPickerButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.primaryText)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
        }
    }
}
