import SwiftUI

struct CalorieResultSheet: View {
    let transcription: String?
    let nutritionResponse: NutritionResponse?
    let isLoading: Bool

    @Environment(\.dismiss) private var dismiss
    @StateObject private var mealLogger = MealLogger.shared
    @State private var hasAppeared = false
    @State private var shimmerPhase: CGFloat = 0
    @State private var contentRevealed = false
    @State private var isSaved = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let transcription = transcription {
                        transcriptionCard(transcription)
                    }
                    nutritionCard
                }
                .padding(16)
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
        .onChange(of: nutritionResponse != nil) { _, hasResponse in
            if hasResponse {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    contentRevealed = true
                }
            }
        }
    }
    
    // MARK: - Transcription Card
    
    private func transcriptionCard(_ transcription: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What you said", systemImage: "mic.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(transcription)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 10)
    }
    
    // MARK: - Nutrition Card
    
    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Nutrition Information", systemImage: "chart.bar.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            if let response = nutritionResponse {
                switch response {
                case .success(let analysis):
                    VStack(spacing: 14) {
                        nutritionContent(analysis)

                        Button {
                            HapticManager.shared.medium()
                            mealLogger.logMeal(transcription: transcription, nutritionResponse: response)
                            isSaved = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))

                                Text(isSaved ? "Added to Diary" : "Add to Meal Diary")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(isSaved ? .green : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSaved ? Color.green.opacity(0.2) : Color.accentColor)
                            )
                        }
                        .disabled(isSaved)
                    }
                case .failure(let error, _):
                    errorContent(error)
                }
            } else if isLoading {
                loadingSkeleton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 10)
    }
    
    // MARK: - Nutrition Content (with staggered reveal)
    
    private func nutritionContent(_ analysis: NutritionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section 1: Meal Type & Description
            VStack(alignment: .leading, spacing: 4) {
                Text(analysis.mealType)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(analysis.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .modifier(RevealModifier(delay: 0, revealed: contentRevealed))

            Divider()
                .modifier(RevealModifier(delay: 0.05, revealed: contentRevealed))

            // Section 2: Calories + Macros Combined
            HStack(spacing: 12) {
                // Total Calories
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calories")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(analysis.totalCalories))")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text("kcal")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .modifier(RevealModifier(delay: 0.1, revealed: contentRevealed))

                Spacer()

                // Macros
                HStack(spacing: 10) {
                    macroPill(label: "P", value: analysis.totalProtein, color: .blue)
                    macroPill(label: "C", value: analysis.totalCarbs, color: .orange)
                    macroPill(label: "F", value: analysis.totalFats, color: .purple)
                }
                .modifier(RevealModifier(delay: 0.15, revealed: contentRevealed))
            }

            Divider()
                .modifier(RevealModifier(delay: 0.2, revealed: contentRevealed))

            // Section 3: Breakdown
            VStack(alignment: .leading, spacing: 10) {
                Text("Breakdown")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .modifier(RevealModifier(delay: 0.25, revealed: contentRevealed))

                ForEach(Array(analysis.breakdown.enumerated()), id: \.element.id) { index, item in
                    breakdownRow(item)
                        .modifier(RevealModifier(delay: 0.3 + Double(index) * 0.05, revealed: contentRevealed))
                }
            }
        }
    }
    
    private func macroPill(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)

            Text("\(Int(value))g")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .frame(width: 44)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.12))
        )
    }
    
    private func breakdownRow(_ item: NutritionItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Item name, portion, and calories
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.item)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(item.portion)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(item.calories))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                + Text(" kcal")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            // Macros + Micros in same row
            HStack(spacing: 0) {
                // Macros
                HStack(spacing: 12) {
                    miniMacro(label: "P", value: item.protein, color: .blue)
                    miniMacro(label: "C", value: item.carbs, color: .orange)
                    miniMacro(label: "F", value: item.fats, color: .purple)
                }

                if !item.micros.isEmpty {
                    Text(" • ")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)

                    Text(item.micros.joined(separator: " • "))
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.quaternarySystemFill))
        )
    }
    
    private func miniMacro(label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)

            Text("\(Int(value))g")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Error Content
    
    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.orange)
            
            Text("Couldn't analyze meal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - Loading Skeleton (mirrors exact layout)
    
    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Matches: Meal Type & Description
            VStack(alignment: .leading, spacing: 4) {
                shimmer(width: 50, height: 11)
                shimmer(width: 200, height: 15)
            }

            Divider()

            // Matches: Calories + Macros Combined
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    shimmer(width: 55, height: 11)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        shimmer(width: 70, height: 28)
                        shimmer(width: 30, height: 12)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    shimmer(width: 44, height: 40)
                    shimmer(width: 44, height: 40)
                    shimmer(width: 44, height: 40)
                }
            }

            Divider()

            // Matches: Breakdown
            VStack(alignment: .leading, spacing: 10) {
                shimmer(width: 70, height: 11)

                ForEach(0..<2, id: \.self) { _ in
                    skeletonBreakdownRow
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                shimmerPhase = 1
            }
        }
    }
    
    private var skeletonBreakdownRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    shimmer(width: 130, height: 14)
                    shimmer(width: 70, height: 12)
                }
                Spacer()
                shimmer(width: 60, height: 16)
            }

            HStack(spacing: 12) {
                shimmer(width: 30, height: 11)
                shimmer(width: 30, height: 11)
                shimmer(width: 30, height: 11)
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.quaternarySystemFill))
        )
    }
    
    // MARK: - Shimmer Effect
    
    private func shimmer(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: height / 3)
            .fill(
                LinearGradient(
                    colors: [
                        Color(.systemGray5),
                        Color(.systemGray4).opacity(0.7 + shimmerPhase * 0.3),
                        Color(.systemGray5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
    }
}

// MARK: - Reveal Animation Modifier

private struct RevealModifier: ViewModifier {
    let delay: Double
    let revealed: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay), value: revealed)
    }
}

// MARK: - Previews

#Preview("Success") {
    CalorieResultSheet(
        transcription: "I had a chicken breast with rice and broccoli",
        nutritionResponse: .success(.preview),
        isLoading: false
    )
}

#Preview("Loading") {
    CalorieResultSheet(
        transcription: "I had a chicken breast with rice and broccoli",
        nutritionResponse: nil,
        isLoading: true
    )
}

#Preview("Error") {
    CalorieResultSheet(
        transcription: "asdfghjkl",
        nutritionResponse: .failure(error: "Could not parse meal", unparseableMeal: "asdfghjkl"),
        isLoading: false
    )
}

// Interactive preview to test loading → success transition
#Preview("Loading → Success") {
    struct TransitionDemo: View {
        @State private var response: NutritionResponse? = nil
        @State private var isLoading = true
        
        var body: some View {
            CalorieResultSheet(
                transcription: "I had a chicken breast with rice and broccoli",
                nutritionResponse: response,
                isLoading: isLoading
            )
            .onAppear {
                // Simulate API delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    response = .success(.preview)
                    isLoading = false
                }
            }
        }
    }
    return TransitionDemo()
}
