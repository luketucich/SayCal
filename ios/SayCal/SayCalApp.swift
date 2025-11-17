import SwiftUI

@main
struct SayCalApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    // Show loading screen while checking auth status
                    LoadingView()
                } else if authManager.isAuthenticated {
                    // User is logged in - check onboarding status
                    OnboardingCheckView()
                } else {
                    // User is not logged in - show welcome/onboarding
                    WelcomeView()
                }
            }
            .environmentObject(authManager)
            .environmentObject(profileManager)
        }
    }
}

// Checks if user has completed onboarding
struct OnboardingCheckView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var profileManager: ProfileManager
    @State private var isCheckingOnboarding = true
    @State private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if isCheckingOnboarding {
                LoadingView()
            } else if hasCompletedOnboarding {
                MainAppView()
            } else {
                OnboardingQuizView()
            }
        }
        .task {
            await checkOnboardingStatus()
        }
        .onChange(of: profileManager.userProfile?.onboardingCompleted) { _, newValue in
            if let completed = newValue {
                hasCompletedOnboarding = completed
            }
        }
    }

    private func checkOnboardingStatus() async {
        guard let userId = authManager.currentUser?.id else {
            isCheckingOnboarding = false
            return
        }

        hasCompletedOnboarding = await profileManager.hasCompletedOnboarding(userId: userId)
        isCheckingOnboarding = false
    }
}

// Simple loading view
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
