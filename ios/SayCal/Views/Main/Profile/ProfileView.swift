import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager

    @State private var isEditing = false
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    @State private var saveAction: (() async -> Void)?

    var body: some View {
        NavigationStack {
            if let profile = userManager.profile {
                if !isEditing {
                    ObserveProfileView(profile: profile)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    HapticManager.shared.light()
                                    isEditing = true
                                } label: {
                                    Text("Edit")
                                        .font(.bodyMedium)
                                        .foregroundColor(.textPrimary)
                                }
                            }
                        }
                } else {
                    EditProfileView(
                        isEditing: $isEditing,
                        isSaving: $isSaving,
                        showSaveSuccess: $showSaveSuccess,
                        saveAction: $saveAction
                    )
                    .id(profile.userId)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: Spacing.md) {
                                Button {
                                    HapticManager.shared.light()
                                    isEditing = false
                                } label: {
                                    Text("Cancel")
                                        .font(.bodyMedium)
                                        .foregroundColor(.textSecondary)
                                }

                                Button {
                                    HapticManager.shared.medium()
                                    Task {
                                        await saveAction?()
                                    }
                                } label: {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .textPrimary))
                                    } else {
                                        Text("Save")
                                            .font(.bodySemibold)
                                            .foregroundColor(.textPrimary)
                                    }
                                }
                                .disabled(isSaving)
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Text("No profile data available")
                        .font(.body)
                        .foregroundStyle(.textSecondary)
                }
                .navigationTitle("Profile")
            }
        }
        .alert("Profile Updated", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile has been updated successfully")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject({
            let manager = UserManager.shared
            return manager
        }())
}
