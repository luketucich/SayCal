import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            if let profile = userManager.profile {
                ScrollView {
                    VStack(spacing: 16) {
                        // Profile Header
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.blue)

                            Text("Profile")
                                .font(.system(size: 24, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)

                        // Quick Stats
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("Quick Stats", icon: "chart.bar.fill")

                            VStack(spacing: 8) {
                                statRow("Target", value: "\(profile.targetCalories) cal")
                                statRow("Goal", value: profile.goal.displayName)
                                statRow("Activity", value: profile.activityLevel.displayName)
                            }
                        }

                        // Divider
                        Divider()
                            .padding(.vertical, 8)

                        // Sign Out
                        Button {
                            HapticManager.shared.medium()
                            showSignOutConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.red.opacity(0.2), lineWidth: 0.5)
                            )
                        }
                        .confirmationDialog("Are you sure you want to sign out?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                            Button("Sign Out", role: .destructive) {
                                Task { try? await userManager.signOut() }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                    .padding(16)
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("No Profile", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 4)
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserManager.shared)
}
