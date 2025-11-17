import SwiftUI

// The "Add" button that shows the custom input field
struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.light()
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                Text("Add")
                    .font(.system(size: 14))
            }
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
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
