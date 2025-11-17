import SwiftUI

struct CodeInputView: View {
    @Binding var code: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    let email: String
    var onVerify: () async -> Void
    var onResend: () async -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            OnboardingHeader(
                title: "Enter verification code",
                subtitle: "We sent a 6-digit code to \(email)"
            )

            VStack(spacing: 16) {
                // Code input boxes
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(code.count == index ? Color(UIColor.label) : Color.primary.opacity(0.3), lineWidth: 1)
                                .frame(width: 48, height: 56)

                            if index < code.count {
                                Text(String(code[code.index(code.startIndex, offsetBy: index)]))
                                    .font(.system(size: 24, weight: .semibold))
                            }
                        }
                    }
                }
                .overlay {
                    // Hidden text field for actual input
                    TextField("", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isFocused)
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .onChange(of: code) { oldValue, newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                code = String(newValue.prefix(6))
                            }
                            // Only allow numbers
                            code = code.filter { $0.isNumber }

                            // Auto-verify when 6 digits entered
                            if code.count == 6 && !isLoading {
                                Task {
                                    await onVerify()
                                }
                            }
                        }
                }
                .onTapGesture {
                    isFocused = true
                }
                .onAppear {
                    isFocused = true
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                PrimaryButton(
                    title: "Verify Code",
                    isEnabled: code.count == 6,
                    isLoading: isLoading
                ) {
                    Task {
                        await onVerify()
                    }
                }

                TextButton(title: "Resend code") {
                    Task {
                        await onResend()
                    }
                }
                .disabled(isLoading)
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(24)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    CodeInputView(
        code: .constant(""),
        isLoading: .constant(false),
        errorMessage: .constant(nil),
        email: "user@example.com",
        onVerify: {},
        onResend: {}
    )
}
