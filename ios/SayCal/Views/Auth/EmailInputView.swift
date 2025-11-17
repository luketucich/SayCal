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
                    .font(.title2)
                    .fontWeight(.bold)

                Text("We'll send you a verification code")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(.system(size: 17))
                    .padding()
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    HapticManager.shared.medium()
                    Task {
                        await onContinue()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    } else {
                        Text("Continue")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .background(email.isEmpty ? Color.gray : Color.accentColor)
                .cornerRadius(32)
                .disabled(email.isEmpty || isLoading)
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
