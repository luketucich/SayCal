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
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Label("Enter verification code", systemImage: "number.circle.fill")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("We sent a 6-digit code to \(email)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)

            VStack(spacing: 16) {
                // Code input boxes
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        CodeDigitBox(
                            digit: index < code.count ? String(code[code.index(code.startIndex, offsetBy: index)]) : "",
                            isActive: code.count == index
                        )
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
                                Task { await onVerify() }
                            }
                        }
                }
                .onTapGesture { isFocused = true }
                .onAppear { isFocused = true }

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
                    Task { await onVerify() }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(Color.appBackground)
                        } else {
                            Text("Verify Code")
                            Image(systemName: "checkmark")
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .disabled(code.count != 6 || isLoading)

                Button {
                    HapticManager.shared.light()
                    Task { await onResend() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Resend code")
                    }
                    .font(.subheadline)
                }
                .disabled(isLoading)
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(24)
    }
}

struct CodeDigitBox: View {
    let digit: String
    let isActive: Bool

    var body: some View {
        Text(digit)
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .frame(width: 48, height: 56)
            .background(Color.appCardBackground, in: RoundedRectangle(cornerRadius: 12))
        .cardShadow()
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
