import SwiftUI
import Supabase

struct EmailInputView: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onContinue: () async -> Void

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            OnboardingHeader(
                title: "Enter your email",
                subtitle: "We'll send you a verification code"
            )

            VStack(spacing: DSSpacing.md) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(DSTypography.bodyLarge)
                    .padding(DSSpacing.md)
                    .frame(height: DSSize.inputMedium)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                    )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color.statusError)
                        .font(DSTypography.captionLarge)
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
        .padding(DSSpacing.xl)
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
