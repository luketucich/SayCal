import SwiftUI

struct GoalStepView: View {
    @Binding var goal: Goal?

    var isValid: Bool {
        goal != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's Your Goal?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("We'll personalize your calorie targets based on your goal.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Goal Options
                VStack(spacing: 16) {
                    GoalCard(
                        goal: .loseWeight,
                        icon: "arrow.down.circle.fill",
                        title: "Lose Weight",
                        description: "Create a calorie deficit to help you lose weight gradually and sustainably",
                        color: .blue,
                        isSelected: goal == .loseWeight,
                        action: { goal = .loseWeight }
                    )

                    GoalCard(
                        goal: .maintainWeight,
                        icon: "equal.circle.fill",
                        title: "Maintain Weight",
                        description: "Maintain your current weight with balanced nutrition",
                        color: .green,
                        isSelected: goal == .maintainWeight,
                        action: { goal = .maintainWeight }
                    )

                    GoalCard(
                        goal: .gainWeight,
                        icon: "arrow.up.circle.fill",
                        title: "Gain Weight",
                        description: "Create a calorie surplus to support healthy weight gain",
                        color: .orange,
                        isSelected: goal == .gainWeight,
                        action: { goal = .gainWeight }
                    )

                    GoalCard(
                        goal: .buildMuscle,
                        icon: "figure.strengthtraining.traditional",
                        title: "Build Muscle",
                        description: "Optimize protein and calories to support muscle growth",
                        color: .purple,
                        isSelected: goal == .buildMuscle,
                        action: { goal = .buildMuscle }
                    )
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : color)
                    .frame(width: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .gray.opacity(0.3))
            }
            .padding()
            .background(isSelected ? color : Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        GoalStepView(goal: .constant(.buildMuscle))
    }
}
