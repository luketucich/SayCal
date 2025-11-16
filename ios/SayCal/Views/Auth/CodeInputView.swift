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
                    .font(.title2)
                    .fontWeight(.bold)

                Text("We sent a 6-digit code to \(email)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                // Code input boxes
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(code.count == index ? Color.accentColor : Color(.systemGray4), lineWidth: 2)
                                .frame(width: 48, height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )

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

                Button {
                    Task {
                        await onVerify()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    } else {
                        Text("Verify Code")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .background(code.count != 6 ? Color.gray : Color.accentColor)
                .cornerRadius(12)
                .disabled(code.count != 6 || isLoading)

                Button {
                    Task {
                        await onResend()
                    }
                } label: {
                    Text("Resend code")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentColor)
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
