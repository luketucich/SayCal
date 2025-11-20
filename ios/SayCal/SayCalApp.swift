import SwiftUI

@main
struct SayCalApp: App {
    @StateObject private var userManager = UserManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if userManager.isLoading {
                    LoadingView()

                } else if userManager.isAuthenticated {
                    if userManager.onboardingCompleted {
                        MainAppView()

                    } else {
                        OnboardingContainerView()
                    }

                } else {
                    WelcomeView()
                }
            }
            .environmentObject(userManager)
        }
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
