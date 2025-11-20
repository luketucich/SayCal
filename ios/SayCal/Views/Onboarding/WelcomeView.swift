import SwiftUI

struct WelcomeView: View {
    @State private var showEmailAuth = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 0.15, green: 0.1, blue: 0.3),
                    Color(red: 0.25, green: 0.15, blue: 0.35),
                    Color(red: 0.1, green: 0.2, blue: 0.3)
                ] : [
                    Color(red: 0.9, green: 0.7, blue: 0.95),
                    Color(red: 0.7, green: 0.85, blue: 1.0),
                    Color(red: 0.95, green: 0.8, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
    
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: DSSpacing.md) {
                    AppleAuthButton()

                    GoogleAuthButton()

                    Button {
                        HapticManager.shared.light()
                        showEmailAuth = true
                    } label: {
                        Text("Use email instead")
                            .font(DSTypography.bodyLarge)
                            .foregroundColor(Color.textPrimary)
                    }
                    .padding(.top, DSSpacing.xxs)
                }
                .padding(.horizontal, DSSpacing.xl)
                .padding(.bottom, DSSpacing.xxxl)
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
