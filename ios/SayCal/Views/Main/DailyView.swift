import SwiftUI

struct DailyView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedDate = Date()
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Date selector card
                    datePickerCard

                    // Calories chart card
                    caloriesChartCard

                    // Quick stats cards
                    quickStatsGrid

                    // Recent meals card
                    recentMealsCard

                    Spacer(minLength: 100)
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.surfaceSecondary)
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Date Picker Card
    private var datePickerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(formattedDate)
                    .font(DesignSystem.Typography.title3(weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Today")
                    .font(DesignSystem.Typography.footnote(weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            Button {
                HapticManager.shared.light()
                showDatePicker.toggle()
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                    )
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Calories Chart Card
    private var caloriesChartCard: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Your Progress")
                    .font(DesignSystem.Typography.headline(weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()
            }

            CaloriesPieChart(
                proteinColor: Color(red: 0.3, green: 0.6, blue: 1.0),
                carbsColor: Color(red: 0.25, green: 0.85, blue: 0.55),
                fatsColor: Color(red: 1.0, green: 0.6, blue: 0.3),
                remainingCalories: 1847
            )
            .frame(height: 280)
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }

    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSystem.Spacing.md) {
            StatCard(
                title: "Meals",
                value: "3",
                icon: "fork.knife",
                color: DesignSystem.Colors.success
            )

            StatCard(
                title: "Water",
                value: "6/8",
                icon: "drop.fill",
                color: DesignSystem.Colors.accent
            )

            StatCard(
                title: "Steps",
                value: "8,432",
                icon: "figure.walk",
                color: Color.orange
            )

            StatCard(
                title: "Streak",
                value: "7 days",
                icon: "flame.fill",
                color: DesignSystem.Colors.warning
            )
        }
    }

    // MARK: - Recent Meals Card
    private var recentMealsCard: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            HStack {
                Text("Recent Meals")
                    .font(DesignSystem.Typography.headline(weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Button {
                    HapticManager.shared.light()
                } label: {
                    Text("See All")
                        .font(DesignSystem.Typography.subheadline(weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }

            VStack(spacing: DesignSystem.Spacing.md) {
                MealRowPlaceholder(
                    time: "8:30 AM",
                    name: "Breakfast",
                    calories: "420"
                )

                Divider()

                MealRowPlaceholder(
                    time: "12:45 PM",
                    name: "Lunch",
                    calories: "680"
                )

                Divider()

                MealRowPlaceholder(
                    time: "7:15 PM",
                    name: "Dinner",
                    calories: "550"
                )
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(DesignSystem.Typography.title3(weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text(title)
                    .font(DesignSystem.Typography.caption1(weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Meal Row Placeholder
struct MealRowPlaceholder: View {
    let time: String
    let name: String
    let calories: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(DesignSystem.Typography.callout(weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text(time)
                    .font(DesignSystem.Typography.footnote(weight: .regular))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            Text("\(calories) cal")
                .font(DesignSystem.Typography.callout(weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    Capsule()
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                )
        }
    }
}

#Preview {
    DailyView()
}
