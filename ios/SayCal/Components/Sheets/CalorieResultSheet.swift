import SwiftUI

struct CalorieResultSheet: View {
    let mealId: String

    @ObservedObject var mealLogger = MealManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var hasAppeared = false
    @State private var shimmerPhase: CGFloat = 0
    @State private var contentRevealed = false
    @State private var selectedDetent: PresentationDetent = .medium
    @State private var showDeleteConfirmation = false

    private var meal: LoggedMeal? {
        mealLogger.loggedMeals.first(where: { $0.id == mealId })
    }

    private var transcription: String? {
        meal?.transcription
    }

    private var nutritionResponse: NutritionResponse? {
        meal?.nutritionResponse
    }

    private var isLoading: Bool {
        meal?.isLoading ?? false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if meal == nil {
                    // Meal not found
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Meal not found")
                            .font(.headline)
                        Text("This meal may have been deleted")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            actionButtons
                            nutritionCard
                        }
                        .padding(16)
                    }
                }
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
        .presentationDetents([.medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .presentationContentInteraction(.scrolls)
        .onAppear {
            print("📋 CalorieResultSheet appeared")
            print("   mealId: \(mealId)")
            print("   meal found: \(meal != nil)")
            print("   isLoading: \(isLoading)")
            print("   has nutritionResponse: \(nutritionResponse != nil)")
            print("   total meals in manager: \(mealLogger.loggedMeals.count)")

            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }

            // If data already exists, reveal content immediately
            if nutritionResponse != nil {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                    contentRevealed = true
                }
            }
        }
        .onChange(of: nutritionResponse != nil) { _, hasResponse in
            if hasResponse {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    contentRevealed = true
                }
            }
        }
        .confirmationDialog("Delete this meal?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let meal = meal {
                    HapticManager.shared.medium()
                    mealLogger.deleteMeal(meal)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                HapticManager.shared.light()
                // TODO: Implement edit functionality
            } label: {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Edit")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .foregroundStyle(.primary)
            }

            Button {
                HapticManager.shared.light()
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Delete")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .foregroundStyle(.red)
            }
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 10)
    }

    // MARK: - Nutrition Card
    
    private var nutritionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let response = nutritionResponse {
                switch response {
                case .success(let analysis):
                    nutritionContent(analysis)
                case .failure(let error, _):
                    errorContent(error)
                }
            } else if isLoading {
                loadingSkeleton
            } else {
                Text("No nutrition data available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 32)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
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

                        Text(" cal")
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
                    macroPill(label: "F", value: analysis.totalFats, color: .pink)
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
                .foregroundStyle(color)
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
                + Text(" cal")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            // Macros
            HStack(spacing: 12) {
                miniMacro(label: "P", value: item.protein, color: .blue)
                miniMacro(label: "C", value: item.carbs, color: .orange)
                miniMacro(label: "F", value: item.fats, color: .pink)
            }

            // Micros (if available, on separate line)
            if !item.micros.isEmpty {
                Text(item.micros.joined(separator: " • "))
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
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
                .foregroundStyle(color)
        }
    }
    
    // MARK: - Error Content
    
    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

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
        ZStack {
            RoundedRectangle(cornerRadius: height / 3)
                .fill(Color(.systemGray5))
                .frame(width: width, height: height)

            RoundedRectangle(cornerRadius: height / 3)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(.systemGray4).opacity(0.5),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .offset(x: shimmerPhase * width * 2 - width)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        shimmerPhase = 1
                    }
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: height / 3))
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

#Preview("Meal Sheet") {
    // Create a preview meal
    let previewMealId = "preview-meal"
    let logger = MealManager.shared

    // Add preview meal if it doesn't exist
    if !logger.loggedMeals.contains(where: { $0.id == previewMealId }) {
        let meal = LoggedMeal(
            id: previewMealId,
            transcription: "I had a chicken breast with rice and broccoli",
            nutritionResponse: .success(.preview),
            isLoading: false
        )
        logger.loggedMeals.append(meal)
    }

    return CalorieResultSheet(mealId: previewMealId)
}
