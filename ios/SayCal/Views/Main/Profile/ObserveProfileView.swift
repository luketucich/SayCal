import SwiftUI

struct ObserveProfileView: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Your Profile")
                        .font(DesignSystem.Typography.largeTitle(weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("View and manage your information")
                        .font(DesignSystem.Typography.body(weight: .regular))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.top, DesignSystem.Spacing.lg)

                VStack(spacing: 24) {
                    ProfileSection(title: "Goals") {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                    Text("Your Target Calories")
                                        .font(DesignSystem.Typography.subheadline(weight: .medium))
                                        .foregroundColor(DesignSystem.Colors.textSecondary)

                                    Text("\(profile.targetCalories)")
                                        .font(.system(size: 42, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: DesignSystem.Colors.primaryGradient,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )

                                    Text("calories per day")
                                        .font(DesignSystem.Typography.footnote(weight: .regular))
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                }

                                Spacer()
                            }
                            .padding(DesignSystem.Spacing.xl)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                    .fill(
                                        LinearGradient(
                                            colors: DesignSystem.Colors.primaryGradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .opacity(0.1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                                            .stroke(
                                                LinearGradient(
                                                    colors: DesignSystem.Colors.primaryGradient,
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                .opacity(0.3),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: DesignSystem.Colors.primary.opacity(0.1), radius: 12, x: 0, y: 6)

                            HStack(spacing: 12) {
                                MacroDisplayCard(
                                    title: "Carbs",
                                    percentage: profile.carbsPercent,
                                    color: .blue
                                )

                                MacroDisplayCard(
                                    title: "Fats",
                                    percentage: profile.fatsPercent,
                                    color: .orange
                                )

                                MacroDisplayCard(
                                    title: "Protein",
                                    percentage: profile.proteinPercent,
                                    color: .green
                                )
                            }

                            ProfileInfoCard(label: "Goal", value: profile.goal.displayName)
                            ProfileInfoCard(label: "Activity Level", value: profile.activityLevel.displayName)
                        }
                    }

                    ProfileSection(title: "Basic Information") {
                        VStack(spacing: 12) {
                            ProfileInfoCard(label: "Sex", value: profile.sex.displayName)
                            ProfileInfoCard(label: "Age", value: "\(profile.age) years")
                            ProfileInfoCard(label: "Units", value: profile.unitsPreference.displayName)
                        }
                    }

                    ProfileSection(title: "Physical Stats") {
                        VStack(spacing: 12) {
                            if profile.unitsPreference == .imperial {
                                let (feet, inches) = profile.heightCm.cmToFeetAndInches
                                ProfileInfoCard(label: "Height", value: "\(feet)' \(inches)\"")
                            } else {
                                ProfileInfoCard(label: "Height", value: "\(profile.heightCm) cm")
                            }

                            if profile.unitsPreference == .imperial {
                                let lbs = profile.weightKg.kgToLbs
                                ProfileInfoCard(label: "Weight", value: String(format: "%.1f lbs", lbs))
                            } else {
                                ProfileInfoCard(label: "Weight", value: String(format: "%.1f kg", profile.weightKg))
                            }
                        }
                    }

                    ProfileSection(title: "Dietary Preferences") {
                        if let preferences = profile.dietaryPreferences, !preferences.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(preferences, id: \.self) { preference in
                                    ProfilePillBadge(text: preference.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                        }
                    }

                    ProfileSection(title: "Allergies") {
                        if let allergies = profile.allergies, !allergies.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(allergies, id: \.self) { allergy in
                                    ProfilePillBadge(text: allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                        }
                    }

                    Button(action: {
                        HapticManager.shared.medium()
                        Task {
                            do {
                                try await userManager.signOut()
                            } catch {
                                // TODO: Add proper pop up later
                                print("Sign out failed: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Sign Out")
                                .font(DesignSystem.Typography.callout(weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(DesignSystem.Colors.error)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .fill(DesignSystem.Colors.error.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .stroke(DesignSystem.Colors.error.opacity(0.3), lineWidth: 1.5)
                                )
                        )
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.caption1(weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            content
        }
    }
}

struct ProfileInfoCard: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.callout(weight: .medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(DesignSystem.Typography.callout(weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.borderSubtle, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct ProfilePillBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.subheadline(weight: .medium))
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.primary.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct MacroDisplayCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(DesignSystem.Typography.caption1(weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text("\(percentage)%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(color.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}
