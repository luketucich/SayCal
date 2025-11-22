import SwiftUI
import Supabase

struct EmailInputView: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    var onContinue: () async -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            OnboardingHeader(
                title: "Enter your email",
                subtitle: "We'll send you a verification code"
            )

            VStack(spacing: AppSpacing.md) {
                TextField("Email address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(AppTypography.body)
                    .padding(AppSpacing.md)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(AppColors.error)
                        .font(AppTypography.smallCaption)
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
        .padding(AppSpacing.xl)
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
