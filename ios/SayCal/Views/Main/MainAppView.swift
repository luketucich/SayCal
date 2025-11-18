import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        TabView {
            DailyView()
                .tabItem {
                    Label("Daily", systemImage: "chart.pie.fill")
                }

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject({
            let manager = AuthManager()
            // Note: onboardingCompleted is now a computed property
            // Preview will work once a profile is loaded in UserProfileManager
            return manager
        }())
}
