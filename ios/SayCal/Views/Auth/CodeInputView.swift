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
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter verification code")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)

                Text("We sent a 6-digit code to \(email)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .frame(width: 48, height: 56)

                            RoundedRectangle(cornerRadius: 8)
                                .stroke(code.count == index ? Color.blue : Color.primary.opacity(0.3), lineWidth: code.count == index ? 2 : 1)
                                .frame(width: 48, height: 56)

                            if index < code.count {
                                Text(String(code[code.index(code.startIndex, offsetBy: index)]))
                                    .font(.system(size: 24, weight: .semibold))
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
                        .opacity(0.01)
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
                        .foregroundStyle(.red)
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
