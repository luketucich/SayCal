import SwiftUI
import AuthenticationServices

struct OnboardingBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Get Started")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Sample text will go here.")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                SignInWithAppleButton(.continue) { request in
                    dismiss()
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    // TODO: Handle Supabase Auth
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 56)
                .cornerRadius(16)
                
                Button {
                    // Handle Google sign in
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
                
                Button {
                    // Handle Email sign in
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Continue with Email")
                            .font(.system(size: 22, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}
