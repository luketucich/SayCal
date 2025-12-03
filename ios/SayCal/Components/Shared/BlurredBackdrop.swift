import SwiftUI

struct BlurredBackdrop: View {
    let isVisible: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if isVisible {
            // Simple semi-transparent overlay with very subtle blur
            (colorScheme == .dark ? Color.black : Color.gray)
                .opacity(colorScheme == .dark ? 0.4 : 0.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity)
                .onTapGesture {
                    onTap()
                }
        }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()

        BlurredBackdrop(isVisible: true, onTap: {})
    }
}
