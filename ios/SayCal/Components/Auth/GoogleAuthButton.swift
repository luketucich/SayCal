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
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    // Option 1: Use official Google logo from Assets
                    // Uncomment this if you add google-logo to Assets.xcassets:
                    // Image("google-logo")
                    //     .resizable()
                    //     .frame(width: 20, height: 20)
                    
                    // Option 2: Using SF Symbol as fallback
                    // Image(systemName: "g.circle.fill")
                    //     .font(.system(size: 20))
                    
                    // Option 3: Simple text "G" (current)
                    Text("G")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Sign in with Google")
                        .font(.system(size: 22, weight: .medium))
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
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
    }
}

#Preview {
    GoogleAuthButton()
}
