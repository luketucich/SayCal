import SwiftUI

struct CalorieResultSheet: View {
    let transcription: String?
    let nutritionInfo: String
    let isLoading: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let transcription = transcription {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("What you said", systemImage: "mic.fill")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)

                                Text(transcription)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }

                    Divider()

                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)

                            Text("Calculating nutrition...")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Nutrition Information", systemImage: "chart.bar.fill")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)

                                Text(nutritionInfo)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Meal Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
