import SwiftUI
import Supabase

struct EmailInputView: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onContinue: () async -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            OnboardingHeader(
                title: "Enter your email",
                subtitle: "We'll send you a verification code"
            )

            VStack(spacing: Spacing.md) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(.body)
                    .padding(Spacing.md)
                    .frame(height: Dimensions.buttonHeightMedium)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .stroke(Color.border.opacity(Opacity.visible), lineWidth: LineWidth.thin)
                    )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.error)
                        .font(.smallCaption)
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
        .padding(Spacing.xl)
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
