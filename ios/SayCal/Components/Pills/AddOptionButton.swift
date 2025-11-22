import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: Theme.Spacing.xxs) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                Text("Add")
                    .font(Theme.Typography.caption)
            }
            .foregroundColor(Theme.Colors.secondaryLabel)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs + 2)
            .background(
                Capsule()
                    .fill(Theme.Colors.secondaryBackground)
            )
            .overlay(
                Capsule()
                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
            .cardShadow()
        }
    }
}

#Preview {
    AddOptionButton {}
        .padding()
        .background(Color(UIColor.systemBackground))
}
