import SwiftUI

struct ActivityStepView: View {
    @Binding var workoutsPerWeek: Int
    @Binding var activityLevel: ActivityLevel?

    var isValid: Bool {
        activityLevel != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Activity Level")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Help us understand your daily routine and exercise habits.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Workouts Per Week
                VStack(alignment: .leading, spacing: 12) {
                    Text("How many days per week do you exercise?")
                        .font(.headline)

                    HStack(spacing: 12) {
                        ForEach(0...7, id: \.self) { count in
                            Button(action: { workoutsPerWeek = count }) {
                                Text("\(count)")
                                    .font(.headline)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background(
                                        workoutsPerWeek == count ?
                                        Color.accentColor : Color.gray.opacity(0.1)
                                    )
                                    .foregroundColor(
                                        workoutsPerWeek == count ?
                                        .white : .primary
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // Activity Level
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your typical daily activity level?")
                        .font(.headline)

                    VStack(spacing: 12) {
                        ActivityLevelCard(
                            level: .sedentary,
                            title: "Sedentary",
                            description: "Little or no exercise, desk job",
                            isSelected: activityLevel == .sedentary,
                            action: { activityLevel = .sedentary }
                        )

                        ActivityLevelCard(
                            level: .lightlyActive,
                            title: "Lightly Active",
                            description: "Light exercise 1-3 days/week",
                            isSelected: activityLevel == .lightlyActive,
                            action: { activityLevel = .lightlyActive }
                        )

                        ActivityLevelCard(
                            level: .moderatelyActive,
                            title: "Moderately Active",
                            description: "Moderate exercise 3-5 days/week",
                            isSelected: activityLevel == .moderatelyActive,
                            action: { activityLevel = .moderatelyActive }
                        )

                        ActivityLevelCard(
                            level: .veryActive,
                            title: "Very Active",
                            description: "Hard exercise 6-7 days/week",
                            isSelected: activityLevel == .veryActive,
                            action: { activityLevel = .veryActive }
                        )

                        ActivityLevelCard(
                            level: .extremelyActive,
                            title: "Extremely Active",
                            description: "Very hard exercise, physical job or training twice per day",
                            isSelected: activityLevel == .extremelyActive,
                            action: { activityLevel = .extremelyActive }
                        )
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
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
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        ActivityStepView(
            workoutsPerWeek: .constant(3),
            activityLevel: .constant(.moderatelyActive)
        )
    }
}
