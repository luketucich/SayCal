import SwiftUI

struct WelcomeView: View {
    @State private var showEmailAuth = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    AppleAuthButton()

                    GoogleAuthButton()

                    Button {
                        HapticManager.shared.light()
                        showEmailAuth = true
                    } label: {
                        Text("Use email instead")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
