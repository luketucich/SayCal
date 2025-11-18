// Main app entry point that manages authentication flow and routing between welcome, onboarding, and main app views

import SwiftUI

@main
struct SayCalApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isLoading {
                    LoadingView()
                    
                } else if authManager.isAuthenticated {
                    if authManager.onboardingCompleted {
                        MainAppView()
                        
                    } else {
                        OnboardingContainerView()
                    }
                    
                } else {
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
