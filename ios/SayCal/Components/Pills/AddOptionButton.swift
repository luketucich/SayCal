import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "plus")
                    .font(DSTypography.labelSmall)
                Text("Add")
                    .font(DSTypography.labelMedium)
            }
            .foregroundColor(Color.textSecondary)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                Capsule()
                    .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                    .background(
                        Capsule()
                            .fill(Color.backgroundTertiary)
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
