import SwiftUI
import Supabase

struct EmailAuthView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager

    @State private var email = ""
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCodeInput = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if showCodeInput {
                    CodeInputView(
                        code: $code,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        email: email,
                        onVerify: verifyCode,
                        onResend: sendOTP
                    )
                    .transition(.move(edge: .trailing))
                } else {
                    EmailInputView(
                        email: $email,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        onContinue: sendOTP
                    )
                    .transition(.move(edge: .leading))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.light()
                        dismiss()
                    }
                }
                
                if showCodeInput {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Back") {
                            HapticManager.shared.light()
                            withAnimation {
                                showCodeInput = false
                                code = ""
                                errorMessage = nil
                            }
                        }
                    }
                }
            }
        }
    }

    private func sendOTP() async {
        errorMessage = nil
        isLoading = true

        do {
            try await SupabaseManager.client.auth.signInWithOTP(
                email: email
            )

            withAnimation {
                showCodeInput = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func verifyCode() async {
        errorMessage = nil
        isLoading = true

        do {
            try await SupabaseManager.client.auth.verifyOTP(
                email: email,
                token: code,
                type: .email
            )

            dismiss()
        } catch {
            errorMessage = "Invalid code. Please try again."
            code = ""
        }

        isLoading = false
    }
}

#Preview {
    EmailAuthView()
        .environmentObject(UserManager.shared)
}
