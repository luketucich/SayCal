import SwiftUI

struct FloatingAddButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.medium()
            onTap()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 59, height: 59)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FloatingAddButton(onTap: {})
}
