import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "plus")
                    .font(.iconSmall)
                Text("Add")
                    .font(.caption)
            }
            .foregroundColor(.textSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .stroke(Color.borderSubtle, lineWidth: LineWidth.thin)
                    .background(
                        Capsule()
                            .fill(Color.overlayBackground)
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
