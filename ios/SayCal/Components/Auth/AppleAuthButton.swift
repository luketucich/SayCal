import SwiftUI
import AuthenticationServices
import Supabase

struct AppleAuthButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
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
        .cornerRadius(AppCornerRadius.pill)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 4)
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
            do {
                let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
                guard
                    let credential = credential,
                    let idToken = credential.identityToken
                        .flatMap({ String(data: $0, encoding: .utf8) })
                else { return }

                try await SupabaseManager.client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken)
                )

                if let fullName = credential.fullName {
                    let nameParts = [
                        fullName.givenName,
                        fullName.middleName,
                        fullName.familyName
                    ].compactMap { $0 }.filter { !$0.isEmpty }

                    let fullNameString = nameParts.joined(separator: " ")

                    try await SupabaseManager.client.auth.update(
                        user: UserAttributes(
                            data: [
                                "full_name": .string(fullNameString),
                                "given_name": .string(fullName.givenName ?? ""),
                                "family_name": .string(fullName.familyName ?? "")
                            ]
                        )
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

#Preview {
    AppleAuthButton()
}
