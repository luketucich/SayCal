import SwiftUI
import AuthenticationServices

struct AuthSheet: View {
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
                AppleAuthButton()
                
                // Google
                GoogleAuthButton()
                
                // Email
                EmailAuthButton()
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

#Preview {
    AuthSheet()
}
