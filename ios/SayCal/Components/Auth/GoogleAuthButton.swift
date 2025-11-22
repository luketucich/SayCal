import SwiftUI
import GoogleSignIn
import Supabase

struct GoogleAuthButton: View {
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Button {
                HapticManager.shared.medium()
                Task {
                    do {
                        try await googleSignIn()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                HStack(spacing: Theme.Spacing.xs) {
                    Text("G")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Sign in with Google")
                        .font(.system(size: 22, weight: .medium))
                }
                .foregroundColor(Theme.Colors.label)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.ButtonSize.large)
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(Theme.Colors.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.standard)
                )
                .mediumShadow()
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(Theme.Colors.error)
                    .font(Theme.Typography.small)
                    .padding(.top, Theme.Spacing.xxs)
            }
        }
    }
    
    private func googleSignIn() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No idToken found"])
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        try await SupabaseManager.client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .google,
                idToken: idToken,
                accessToken: accessToken
            )
        )
    }
}

#Preview {
    GoogleAuthButton()
}
