import SwiftUI
import Supabase

struct EmailInputView: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onContinue: () async -> Void

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(
                title: "Enter your email",
                subtitle: "We'll send you a verification code"
            )

            VStack(spacing: 16) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(.system(size: 17))
                    .padding()
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.Colors.background)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )
                    .cardShadow()

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                PrimaryButton(
                    title: "Continue",
                    isEnabled: !email.isEmpty,
                    isLoading: isLoading
                ) {
                    Task {
                        await onContinue()
                    }
                }
            }

            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    EmailInputView(
        email: .constant(""),
        isLoading: .constant(false),
        errorMessage: .constant(nil),
        onContinue: {}
    )
}
