// User profile view with settings and account information

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager

    // Editing state
    @State private var isEditing = false

    // Loading state
    @State private var isSaving = false
    @State private var showSaveSuccess = false

    // Save callback that EditProfileView will provide
    @State private var saveAction: (() async -> Void)?

    var body: some View {
        NavigationStack {
            if let profile = authManager.cachedProfile {
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
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(UIColor.label))
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
                    .id(profile.userId) // Force refresh when profile changes
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 16) {
                                Button {
                                    HapticManager.shared.light()
                                    isEditing = false
                                } label: {
                                    Text("Cancel")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }

                                Button {
                                    HapticManager.shared.medium()
                                    Task {
                                        await saveAction?()
                                    }
                                } label: {
                                    if isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.label)))
                                    } else {
                                        Text("Save")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(UIColor.label))
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
                        .foregroundStyle(.secondary)
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
            let manager = AuthManager()
            // Note: onboardingCompleted is now a computed property
            // Preview will work once a profile is loaded in UserProfileManager
            return manager
        }())
}
