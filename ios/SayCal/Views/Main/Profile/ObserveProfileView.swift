import SwiftUI

struct ObserveProfileView: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                OnboardingHeader(
                    title: "Your Profile",
                    subtitle: "View and manage your information"
                )

                VStack(spacing: Spacing.xl) {
                    ProfileSection(title: "Goals") {
                        VStack(spacing: Spacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    Text("Your Target Calories")
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)

                                    Text("\(profile.targetCalories)")
                                        .font(.displayLarge)
                                        .foregroundColor(.textPrimary)

                                    Text("calories per day")
                                        .font(.smallCaption)
                                        .foregroundColor(.textTertiary)
                                }

                                Spacer()
                            }
                            .padding(Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(Color(UIColor.systemGray6))
                            )

                            HStack(spacing: Spacing.sm) {
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
                        VStack(spacing: Spacing.sm) {
                            ProfileInfoCard(label: "Sex", value: profile.sex.displayName)
                            ProfileInfoCard(label: "Age", value: "\(profile.age) years")
                            ProfileInfoCard(label: "Units", value: profile.unitsPreference.displayName)
                        }
                    }

                    ProfileSection(title: "Physical Stats") {
                        VStack(spacing: Spacing.sm) {
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
                            ], spacing: Spacing.xs) {
                                ForEach(preferences, id: \.self) { preference in
                                    ProfilePillBadge(text: preference.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                        }
                    }

                    ProfileSection(title: "Allergies") {
                        if let allergies = profile.allergies, !allergies.isEmpty {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: Spacing.xs) {
                                ForEach(allergies, id: \.self) { allergy in
                                    ProfilePillBadge(text: allergy.replacingOccurrences(of: "_", with: " ").capitalized)
                                }
                            }
                        } else {
                            Text("None")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                                .font(.bodySemibold)
                                .foregroundColor(.error)
                            Spacer()
                        }
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(.error, lineWidth: 1)
                        )
                    }
                }

                Spacer(minLength: 100)
            }
            .padding(.horizontal, Spacing.lg)
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
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.smallCaptionMedium)
                .foregroundColor(.textSecondary)

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
                .font(.caption)
                .foregroundColor(.textSecondary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }
}

struct ProfilePillBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.smallCaptionMedium)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
    }
}

struct MacroDisplayCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Text(title)
                .font(.smallCaptionMedium)
                .foregroundColor(.textSecondary)

            Text("\(percentage)%")
                .font(.title3)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(color.opacity(0.1))
        )
    }
}
