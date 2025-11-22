import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                Text("Add")
                    .font(DesignSystem.Typography.bodySmall)
            }
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                Capsule()
                    .strokeBorder(DesignSystem.Colors.borderLight, lineWidth: DesignSystem.BorderWidth.medium)
                    .background(Capsule().fill(DesignSystem.Colors.cardBackground))
                    .lightShadow()
            )
        }
    }
}

#Preview {
    AddOptionButton {}
        .padding()
        .background(Color(UIColor.systemBackground))
}
