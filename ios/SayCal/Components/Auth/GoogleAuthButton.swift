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
                HStack(spacing: DesignSystem.Spacing.small) {
                    Text("G")
                        .font(.system(size: 20, weight: .bold))

                    Text("Sign in with Google")
                        .font(DesignSystem.Typography.buttonLarge)
                }
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.Dimensions.buttonHeightLarge)
                .background(
                    Capsule()
                        .strokeBorder(DesignSystem.Colors.borderMedium, lineWidth: DesignSystem.BorderWidth.medium)
                        .background(Capsule().fill(DesignSystem.Colors.cardBackground))
                        .lightShadow()
                )
            }
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 4)
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
