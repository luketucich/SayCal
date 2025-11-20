import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var userManager: UserManager

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
            let manager = UserManager()
            // Note: Preview will work once a profile is loaded in UserManager
            return manager
        }())
}
