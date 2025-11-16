import SwiftUI
import GoogleSignIn
import Supabase

struct GoogleAuthButton: View {
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            // Google Sign In Button
            Button {
                Task {
                    do {
                        try await googleSignIn()
                    } catch {
                        errorMessage = error.localizedDescription
                        print("Sign in error: \(error)")
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text("G")
                        .font(.system(size: 20, weight: .bold))
                    Text("Continue with Google")
                        .font(.system(size: 22, weight: .medium))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(.systemGray5))
                .cornerRadius(16)
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
        // Get the root view controller
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
        
        // Print session info
        if let session = SupabaseManager.client.auth.currentSession {
            print("=== GOOGLE SIGN IN SUCCESS ===")
            print("User ID: \(session.user.id)")
            print("Email: \(session.user.email ?? "No email")")
            print("Access Token: \(session.accessToken)")
            print("Refresh Token: \(session.refreshToken)")
            print("Token Type: \(session.tokenType)")
            print("Expires At: \(session.expiresAt)")
            print("Expires In: \(session.expiresIn) seconds")
            print("Provider: \(session.user.appMetadata["provider"] ?? "unknown")")
            print("Created At: \(session.user.createdAt)")
            print("=============================")
        }
    }
}

#Preview {
    GoogleAuthButton()
}
