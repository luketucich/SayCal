import SwiftUI

struct QuizProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(currentStep) of \(totalSteps)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 30) {
        QuizProgressBar(currentStep: 1, totalSteps: 4)
        QuizProgressBar(currentStep: 2, totalSteps: 4)
        QuizProgressBar(currentStep: 3, totalSteps: 4)
        QuizProgressBar(currentStep: 4, totalSteps: 4)
    }
    .padding()
}
