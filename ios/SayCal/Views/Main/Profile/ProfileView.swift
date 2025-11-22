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
                                        .font(AppTypography.bodyMedium)
                                        .foregroundColor(AppColors.primaryText)
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
                            HStack(spacing: AppSpacing.md) {
                                Button {
                                    HapticManager.shared.light()
                                    isEditing = false
                                } label: {
                                    Text("Cancel")
                                        .font(AppTypography.bodyMedium)
                                        .foregroundColor(AppColors.secondaryText)
                                }

                                Button {
                                    HapticManager.shared.medium()
                                    Task {
                                        await saveAction?()
                                    }
                                } label: {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryText))
                                    } else {
                                        Text("Save")
                                            .font(AppTypography.bodySemibold)
                                            .foregroundColor(AppColors.primaryText)
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
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
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
