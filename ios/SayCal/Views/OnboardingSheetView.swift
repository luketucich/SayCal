import SwiftUI
import AuthenticationServices

struct OnboardingSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // MARK: - Header
            VStack(alignment: .leading, spacing: 16) {
                Text("Get Started")
                    .font(.system(size: 32, weight: .bold))

                Text("Sample text will go here.")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: - Sign-in Buttons
            VStack(spacing: 12) {
                // Apple
                AppleAuthButton(client: SupabaseManager.client, colorScheme: colorScheme)
                
                // Google
                Button {
                    // TODO: Implement Google Sign-In
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

                // Email
                Button {
                    // TODO: Implement Email Sign-In
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 15, weight: .bold))
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

#Preview {
    OnboardingSheetView()
}
