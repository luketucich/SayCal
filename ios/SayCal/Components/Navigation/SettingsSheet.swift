import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @State private var showMacrosAsGrams = false

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
                        Button("Sign Out", role: .destructive) {
                            HapticManager.shared.medium()
                            Task { try? await userManager.signOut() }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
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
