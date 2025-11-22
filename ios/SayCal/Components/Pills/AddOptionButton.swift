import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                Text("Add")
                    .font(AppTypography.caption)
            }
            .foregroundColor(AppColors.secondaryText)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
            )
        }
    }
}

#Preview {
    AddOptionButton {}
        .padding()
        .background(Color(UIColor.systemBackground))
}
