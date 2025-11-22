import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: DesignTokens.FontSize.small, weight: .medium))
                Text("Add")
                    .font(.system(size: DesignTokens.FontSize.label))
            }
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(Color(UIColor.systemGray4), lineWidth: DesignTokens.StrokeWidth.thin)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
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
