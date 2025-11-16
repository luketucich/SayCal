//
//  EmailAuthView.swift
//  SayCal
//
//  Created by Claude on 11/16/25.
//

import SwiftUI
import Supabase

struct EmailAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager

    @State private var email = ""
    @State private var code = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCodeInput = false

    var body: some View {
        NavigationStack {
            ZStack {
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
            .navigationTitle("Email Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if showCodeInput {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Back") {
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

            print("=== EMAIL OTP SENT ===")
            print("Email: \(email)")
            print("======================")

            withAnimation {
                showCodeInput = true
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to send OTP: \(error.localizedDescription)")
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

            // Print session info
            if let session = SupabaseManager.client.auth.currentSession {
                print("=== EMAIL OTP VERIFICATION SUCCESS ===")
                print("User ID: \(session.user.id)")
                print("Email: \(session.user.email ?? "No email")")
                print("Access Token: \(session.accessToken)")
                print("Refresh Token: \(session.refreshToken)")
                print("Token Type: \(session.tokenType)")
                print("Expires At: \(session.expiresAt)")
                print("Expires In: \(session.expiresIn) seconds")
                print("Provider: \(session.user.appMetadata["provider"] ?? "unknown")")
                print("Created At: \(session.user.createdAt)")
                print("=======================================")
            }

            // Dismiss the view - auth manager will handle the state update
            dismiss()
        } catch {
            errorMessage = "Invalid code. Please try again."
            code = ""
            print("Failed to verify OTP: \(error.localizedDescription)")
        }

        isLoading = false
    }
}

#Preview {
    EmailAuthView()
        .environmentObject(AuthManager())
}
