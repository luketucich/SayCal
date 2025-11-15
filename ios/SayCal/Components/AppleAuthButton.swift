import SwiftUI
import AuthenticationServices
import Supabase

struct AppleAuthButton: View {
    let client: SupabaseClient
    let colorScheme: ColorScheme

    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.email, .fullName]
            },
            onCompletion: { result in
                Task {
                    await handleAppleSignIn(result)
                }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 56)
        .cornerRadius(16)
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
            do {
                let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
                guard
                    let credential = credential,
                    let idToken = credential.identityToken
                        .flatMap({ String(data: $0, encoding: .utf8) })
                else { return }

                try await client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken)
                )
                
                // Print session info
                if let session = client.auth.currentSession {
                    print("=== APPLE SIGN IN SUCCESS ===")
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

                // Update user metadata (only on first sign-in)
                if let fullName = credential.fullName {
                    let nameParts = [
                        fullName.givenName,
                        fullName.middleName,
                        fullName.familyName
                    ].compactMap { $0 }.filter { !$0.isEmpty }

                    let fullNameString = nameParts.joined(separator: " ")

                    try await client.auth.update(
                        user: UserAttributes(
                            data: [
                                "full_name": .string(fullNameString),
                                "given_name": .string(fullName.givenName ?? ""),
                                "family_name": .string(fullName.familyName ?? "")
                            ]
                        )
                    )
                    
                    print("User metadata updated: \(fullNameString)")
                }
            } catch {
                print("Sign in with Apple failed: \(error.localizedDescription)")
                // TODO: Show user-facing error
            }
        }
    }

#Preview {
    AppleAuthButton(
        client: SupabaseManager.client,
        colorScheme: .light
    )
}
