import SwiftUI
import Supabase

struct EmailInputView: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onContinue: () async -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your email")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("We'll send you a verification code")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)

            VStack(spacing: 16) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(.body)
                    .padding()
                    .frame(height: 52)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
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
