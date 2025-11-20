import SwiftUI

struct ObserveProfileView: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.xxl) {
                OnboardingHeader(
                    title: "Your Profile",
                    subtitle: "View and manage your information"
                )

                VStack(spacing: DSSpacing.xl) {
                    ProfileSection(title: "Goals") {
                        VStack(spacing: DSSpacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                    Text("Your Target Calories")
                                        .font(DSTypography.bodyMedium)
                                        .foregroundColor(Color.textSecondary)

                                    Text("\(profile.targetCalories)")
                                        .font(DSTypography.displayMedium)
                                        .foregroundColor(Color.textPrimary)

                                    Text("calories per day")
                                        .font(DSTypography.bodySmall)
                                        .foregroundColor(Color.textTertiary)
                                }

                                Spacer()
                            }
                            .padding(DSSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: DSRadius.md)
                                    .fill(Color.backgroundTertiary)
                            )

                            HStack(spacing: DSSpacing.sm) {
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
                        VStack(spacing: DSSpacing.sm) {
                            ProfileInfoCard(label: "Sex", value: profile.sex.displayName)
                            ProfileInfoCard(label: "Age", value: "\(profile.age) years")
                            ProfileInfoCard(label: "Units", value: profile.unitsPreference.displayName)
                        }
                    }

                    ProfileSection(title: "Physical Stats") {
                        VStack(spacing: DSSpacing.sm) {
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
                            ], spacing: DSSpacing.xs) {
                                ForEach(preferences, id: \.self) { preference in
                                    ProfilePillBadge(text: preference.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(DSTypography.bodyMedium)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
                                )
                        }
                    }

                    ProfileSection(title: "Allergies") {
                        if let allergies = profile.allergies, !allergies.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: DSSpacing.xs) {
                                ForEach(allergies, id: \.self) { allergy in
                                    ProfilePillBadge(text: allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(DSTypography.bodyMedium)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
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
                                .font(DSTypography.headingSmall)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .frame(height: DSSize.inputMedium)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .stroke(Color.red, lineWidth: DSBorder.medium)
                        )
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, DSSpacing.lg)
        }
        .background(Color.backgroundPrimary)
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
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .font(DSTypography.labelMedium)
                .foregroundColor(Color.textSecondary)

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
                .font(DSTypography.bodyMedium)
                .foregroundColor(Color.textSecondary)

            Spacer()

            Text(value)
                .font(DSTypography.bodyMedium)
                .foregroundColor(Color.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
        )
    }
}

struct ProfilePillBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(DSTypography.labelMedium)
            .foregroundColor(Color.textPrimary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(Color.borderPrimary, lineWidth: DSBorder.medium)
            )
    }
}

struct MacroDisplayCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: DSSpacing.xxs) {
            Text(title)
                .font(DSTypography.labelSmall)
                .foregroundColor(Color.textSecondary)

            Text("\(percentage)%")
                .font(DSTypography.headingLarge)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(color.opacity(0.1))
        )
    }
}
