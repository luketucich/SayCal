import SwiftUI

struct WelcomeView: View {
    @State private var showEmailAuth = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Theme.Colors.accent.opacity(0.3),
                    Theme.Colors.accent.opacity(0.4),
                    Theme.Colors.accent.opacity(0.2)
                ] : [
                    Theme.Colors.accent.opacity(0.15),
                    Theme.Colors.accent.opacity(0.1),
                    Theme.Colors.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(Theme.Colors.background)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: Theme.Spacing.md) {
                    AppleAuthButton()

                    GoogleAuthButton()

                    Button {
                        HapticManager.shared.light()
                        showEmailAuth = true
                    } label: {
                        Text("Use email instead")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.label)
                    }
                    .padding(.top, Theme.Spacing.xxs)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxxl)
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
        }
    }
}

#Preview("Light Mode") {
    WelcomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    WelcomeView()
        .preferredColorScheme(.dark)
}
