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
        VStack(spacing: Spacing.xl) {
            OnboardingHeader(
                title: "Enter verification code",
                subtitle: "We sent a 6-digit code to \(email)"
            )

            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: CornerRadius.xs)
                                .stroke(code.count == index ? .textPrimary : Color.border.opacity(Opacity.visible), lineWidth: LineWidth.thin)
                                .frame(width: Dimensions.codeInputWidth, height: Dimensions.buttonHeightLarge)

                            if index < code.count {
                                Text(String(code[code.index(code.startIndex, offsetBy: index)]))
                                    .font(.title2)
                            }
                        }
                    }
                }
                .overlay {
                    TextField("", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($isFocused)
                        .frame(width: 1, height: 1)
                        .opacity(Opacity.invisible)
                        .onChange(of: code) { oldValue, newValue in
                            if newValue.count > 6 {
                                code = String(newValue.prefix(6))
                            }
                            code = code.filter { $0.isNumber }

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
                        .foregroundColor(.error)
                        .font(.smallCaption)
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
                .padding(.top, Spacing.xs)
            }

            Spacer()
        }
        .padding(Spacing.xl)
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
