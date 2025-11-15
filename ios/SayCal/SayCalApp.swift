import SwiftUI

@main
struct SayCalApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    // Show loading screen while checking auth status
                    LoadingView()
                } else if authManager.isAuthenticated {
                    // User is logged in - show main app
                    MainAppView()
                } else {
                    // User is not logged in - show welcome/onboarding
                    WelcomeView()
                }
            }
            .environmentObject(authManager)
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
