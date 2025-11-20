import SwiftUI

@main
struct SayCalApp: App {
    @StateObject private var userManager = UserManager.shared

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
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: DSSpacing.md) {
                ProgressView()
                    .scaleEffect(1.5)

                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
