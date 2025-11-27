import SwiftUI

struct EmailInputView: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onContinue: () async -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Label("Enter your email", systemImage: "envelope.fill")
                    .font(.system(size: 28, weight: .bold))

                Text("We'll send you a verification code")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)

            VStack(spacing: 16) {
                // Email field
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .foregroundStyle(.secondary)

                    TextField("Email address", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.background))

                if let errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(errorMessage)
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    HapticManager.shared.medium()
                    Task { await onContinue() }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(Color(.systemBackground))
                        } else {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
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
