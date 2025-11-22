import SwiftUI

struct ObserveProfileView: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                OnboardingHeader(
                    title: "Your Profile",
                    subtitle: "View and manage your information"
                )

                VStack(spacing: AppSpacing.xl) {
                    ProfileSection(title: "Goals") {
                        VStack(spacing: AppSpacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                    Text("Your Target Calories")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.secondaryText)

                                    Text("\(profile.targetCalories)")
                                        .font(AppTypography.displayLarge)
                                        .foregroundColor(AppColors.primaryText)

                                    Text("calories per day")
                                        .font(AppTypography.smallCaption)
                                        .foregroundColor(AppColors.tertiaryText)
                                }

                                Spacer()
                            }
                            .padding(AppSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .fill(Color(UIColor.systemGray6))
                            )

                            HStack(spacing: AppSpacing.sm) {
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
                        VStack(spacing: AppSpacing.sm) {
                            ProfileInfoCard(label: "Sex", value: profile.sex.displayName)
                            ProfileInfoCard(label: "Age", value: "\(profile.age) years")
                            ProfileInfoCard(label: "Units", value: profile.unitsPreference.displayName)
                        }
                    }

                    ProfileSection(title: "Physical Stats") {
                        VStack(spacing: AppSpacing.sm) {
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
                            ], spacing: AppSpacing.xs) {
                                ForEach(preferences, id: \.self) { preference in
                                    ProfilePillBadge(text: preference.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(AppTypography.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                        }
                    }

                    ProfileSection(title: "Allergies") {
                        if let allergies = profile.allergies, !allergies.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: AppSpacing.xs) {
                                ForEach(allergies, id: \.self) { allergy in
                                    ProfilePillBadge(text: allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(AppTypography.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
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
                            Text("Sign Out")
                                .font(AppTypography.bodySemibold)
                                .foregroundColor(AppColors.error)
                            Spacer()
                        }
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(AppColors.error, lineWidth: 1)
                        )
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, AppSpacing.lg)
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
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.smallCaptionMedium)
                .foregroundColor(AppColors.secondaryText)

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
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)

            Spacer()

            Text(value)
                .font(AppTypography.body)
                .foregroundColor(AppColors.primaryText)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }
}

struct ProfilePillBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppTypography.smallCaptionMedium)
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
    }
}

struct MacroDisplayCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.smallCaptionMedium)
                .foregroundColor(AppColors.secondaryText)

            Text("\(percentage)%")
                .font(AppTypography.title3)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(color.opacity(0.1))
        )
    }
}
