import SwiftUI

struct CustomToolbar: View {
    @EnvironmentObject var userManager: UserManager
    let selectedTab: AppTab
    let onTierToggle: () -> Void
    let onReset: () -> Void
    let onSettings: () -> Void
    let onMicronutrients: () -> Void

    private var title: String {
        switch selectedTab {
        case .daily: return "Daily"
        case .recipes: return "Recipes"
        case .add: return ""
        }
    }

    var body: some View {
        ZStack {
            // Centered title (absolutely centered)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                // Left side buttons
                HStack(spacing: 8) {
                    Button {
                        HapticManager.shared.light()
                        onReset()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        HapticManager.shared.medium()
                        onTierToggle()
                    } label: {
                        Image(systemName: userManager.profile?.tier == .premium ? "crown.fill" : "crown")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(userManager.profile?.tier == .premium ? .yellow : .secondary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Right side buttons
                HStack(spacing: 8) {
                    // Micronutrients button
                    Button {
                        HapticManager.shared.light()
                        onMicronutrients()
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    // Settings button
                    Button {
                        HapticManager.shared.light()
                        onSettings()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
