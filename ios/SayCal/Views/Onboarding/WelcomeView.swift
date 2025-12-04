import SwiftUI

struct WelcomeView: View {
    @State private var showEmailAuth = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App branding
            VStack(spacing: 16) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80, design: .rounded))
                    .foregroundStyle(.primary)

                VStack(spacing: 4) {
                    Text("SayCal")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("Track your nutrition effortlessly")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Auth buttons
            VStack(spacing: 12) {
                AppleAuthButton()

                GoogleAuthButton()

                Button {
                    HapticManager.shared.light()
                    showEmailAuth = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                        Text("Continue with Email")
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 12))
        .cardShadow()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Terms
            Text("By continuing, you agree to our Terms of Service")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
        }
        .background(Color.appBackground)
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
