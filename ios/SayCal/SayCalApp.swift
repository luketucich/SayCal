import SwiftUI

@main
struct SayCalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userManager = UserManager.shared

    init() {
        // Start loading WhisperKit model immediately on app launch
        _ = LocalTranscriptionManager.shared

        // Initialize background network manager
        _ = BackgroundNetworkManager.shared
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if userManager.isLoading {
                    LoadingView()

                } else if userManager.isAuthenticated {
                    if userManager.profile?.onboardingCompleted == true {
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
