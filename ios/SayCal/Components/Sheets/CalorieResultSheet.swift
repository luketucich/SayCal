import SwiftUI

struct CalorieResultSheet: View {
    let transcription: String?
    let nutritionInfo: String
    let isLoading: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var hasAppeared = false
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Transcription section
                    if let transcription = transcription {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Text("What you said")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                            }

                            Text(transcription)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 10)
                    }

                    // Nutrition Information section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("Nutrition Information")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                        }

                        if isLoading && nutritionInfo.isEmpty {
                            VStack(spacing: 32) {
                                HStack(spacing: 14) {
                                    ProgressView()
                                        .controlSize(.regular)
                                        .tint(.primary)

                                    Text("Analyzing meal...")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(spacing: 24) {
                                    // Placeholder for total calories
                                    VStack(alignment: .leading, spacing: 12) {
                                        shimmerRectangle(width: 140, height: 16)
                                        shimmerRectangle(width: 180, height: 36)
                                            .opacity(0.8)
                                    }

                                    Divider()
                                        .padding(.vertical, 6)

                                    // Placeholder for macros
                                    VStack(alignment: .leading, spacing: 16) {
                                        shimmerRectangle(width: 100, height: 16)

                                        HStack(spacing: 28) {
                                            ForEach(0..<3) { index in
                                                VStack(alignment: .leading, spacing: 10) {
                                                    shimmerRectangle(width: 55, height: 14)
                                                        .opacity(0.7)
                                                    shimmerRectangle(width: 45, height: 22)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }

                                    Divider()
                                        .padding(.vertical, 6)

                                    // Placeholder for meal breakdown
                                    VStack(alignment: .leading, spacing: 14) {
                                        shimmerRectangle(width: 120, height: 16)
                                            .padding(.bottom, 4)

                                        ForEach(0..<3) { index in
                                            HStack(spacing: 10) {
                                                Circle()
                                                    .fill(shimmerGradient)
                                                    .frame(width: 6, height: 6)
                                                    .opacity(0.6)
                                                shimmerRectangle(width: CGFloat.random(in: 180...250), height: 14)
                                                    .opacity(0.7)
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 24)
                            .onAppear {
                                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                    shimmerOffset = 1
                                }
                            }
                        } else if !nutritionInfo.isEmpty {
                            Text(nutritionInfo)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                                .lineSpacing(6)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 10)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Meal Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Helper Views

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color(.systemGray5), location: 0),
                .init(color: Color(.systemGray4), location: shimmerOffset),
                .init(color: Color(.systemGray5), location: 1)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func shimmerRectangle(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(shimmerGradient)
            .frame(width: width, height: height)
    }
}

#Preview("With Transcription") {
    CalorieResultSheet(
        transcription: "I had a chicken breast with rice and broccoli",
        nutritionInfo: """
        **Meal Summary**

        **Total Calories:** 450 kcal

        **Macronutrients:**
        • Protein: 45g
        • Carbohydrates: 50g
        • Fat: 8g

        **Details:**
        • Chicken breast (6oz): 280 kcal
        • White rice (1 cup): 200 kcal
        • Broccoli (1 cup): 50 kcal
        """,
        isLoading: false
    )
}

#Preview("Loading") {
    CalorieResultSheet(
        transcription: "I had a chicken breast with rice and broccoli",
        nutritionInfo: "",
        isLoading: true
    )
}

#Preview("Text Input") {
    CalorieResultSheet(
        transcription: nil,
        nutritionInfo: """
        **Meal Summary**

        **Total Calories:** 350 kcal

        **Macronutrients:**
        • Protein: 25g
        • Carbohydrates: 40g
        • Fat: 10g
        """,
        isLoading: false
    )
}
