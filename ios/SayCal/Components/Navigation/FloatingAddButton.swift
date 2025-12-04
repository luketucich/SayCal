import SwiftUI

struct FloatingAddButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.medium()
            onTap()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appCardBackground)
                .frame(width: 59, height: 59)
                .background(Color.primary, in: Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color.appStroke, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FloatingAddButton(onTap: {})
}
