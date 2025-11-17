import SwiftUI

struct QuizNavigationButtons: View {
    let canGoBack: Bool
    let canContinue: Bool
    let isLastStep: Bool
    let isLoading: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Back Button
            if canGoBack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
            }

            // Next/Finish Button
            Button(action: onNext) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isLastStep ? "Finish" : "Continue")
                        if !isLastStep {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canContinue ? Color.accentColor : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canContinue || isLoading)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

#Preview {
    VStack(spacing: 30) {
        QuizNavigationButtons(
            canGoBack: false,
            canContinue: true,
            isLastStep: false,
            isLoading: false,
            onBack: {},
            onNext: {}
        )

        QuizNavigationButtons(
            canGoBack: true,
            canContinue: true,
            isLastStep: false,
            isLoading: false,
            onBack: {},
            onNext: {}
        )

        QuizNavigationButtons(
            canGoBack: true,
            canContinue: false,
            isLastStep: false,
            isLoading: false,
            onBack: {},
            onNext: {}
        )

        QuizNavigationButtons(
            canGoBack: true,
            canContinue: true,
            isLastStep: true,
            isLoading: false,
            onBack: {},
            onNext: {}
        )

        QuizNavigationButtons(
            canGoBack: true,
            canContinue: true,
            isLastStep: true,
            isLoading: true,
            onBack: {},
            onNext: {}
        )
    }
    .padding()
}
