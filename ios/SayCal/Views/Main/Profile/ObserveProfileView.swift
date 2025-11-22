import SwiftUI

struct ObserveProfileView: View {
    @EnvironmentObject var userManager: UserManager
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                OnboardingHeader(
                    title: "Your Profile",
                    subtitle: "View and manage your information"
                )

                VStack(spacing: 24) {
                    ProfileSection(title: "Goals") {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Target Calories")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.secondaryLabel))

                                    Text("\(profile.targetCalories)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(UIColor.label))

                                    Text("calories per day")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                }

                                Spacer()
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.Colors.accentLight)
                            )
                            .cardShadow()

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
                                        .fill(Theme.Colors.background)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                                .cardShadow()
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
                                        .fill(Theme.Colors.background)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(UIColor.systemGray5), lineWidth: 1)
                                )
                                .cardShadow()
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
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.Colors.background)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1.5)
                        )
                        .cardShadow()
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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(UIColor.secondaryLabel))

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
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))

            Spacer()

            Text(value)
                .font(.system(size: 16))
                .foregroundColor(Color(UIColor.label))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.Colors.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .cardShadow()
    }
}

struct ProfilePillBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(Color(UIColor.label))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
            )
            .cardShadow()
    }
}

struct MacroDisplayCard: View {
    let title: String
    let percentage: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(UIColor.secondaryLabel))

            Text("\(percentage)%")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .cardShadow()
    }
}
