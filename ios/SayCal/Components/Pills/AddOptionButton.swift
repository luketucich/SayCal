import SwiftUI

struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: DS.Spacing.xxSmall) {
                Image(systemName: "plus")
                    .font(DS.Typography.caption(weight: .medium))
                Text("Add")
                    .font(DS.Typography.footnote())
            }
            .foregroundColor(DS.Colors.secondaryLabel)
            .padding(.horizontal, DS.Spacing.small)
            .padding(.vertical, DS.Spacing.xSmall)
            .background(
                Capsule()
                    .fill(DS.Colors.tertiaryBackground)
                    .overlay(
                        Capsule()
                            .stroke(DS.Colors.separator, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    AddOptionButton {}
        .padding(DS.Spacing.large)
        .background(DS.Colors.background)
}
