import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, RawRepresentable {
    case device = "device"
    case dark = "dark"
    case light = "light"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .device: return "Device"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .device: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }

    var accentColor: Color {
        return .accentColor
    }
}

struct SettingsSheet: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @State private var showMacrosAsGrams = false
    @AppStorage("appTheme") private var selectedTheme: AppTheme = .device

    var body: some View {
        NavigationStack {
            if let profile = userManager.profile {
                List {
                    InteractiveProfileContent(
                        profile: profile,
                        showMacrosAsGrams: $showMacrosAsGrams
                    )
                    .environmentObject(userManager)

                    Section {
                        Picker("Theme", selection: $selectedTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.displayName)
                                    .tag(theme)
                            }
                        }
                    } header: {
                        Label("Appearance", systemImage: "paintbrush.fill")
                    }

                    Section {
                        Button("Sign Out", role: .destructive) {
                            HapticManager.shared.medium()
                            Task { try? await userManager.signOut() }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                ContentUnavailableView("No Profile", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
    }
}

#Preview {
    SettingsSheet()
        .environmentObject(UserManager.shared)
}
