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

// Placeholder views
struct DailyView: View {
    @State private var chart = CaloriesPieChart(
        proteinPercent: 0.30,
        carbsPercent: 0.40,
        fatsPercent: 0.30,
        remainingCalories: 1847,
        totalCalories: 2400
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                chart.frame(width: 200, height: 250)
                Spacer()
            }
        }
    }
}

struct RecipesView: View {
    var body: some View {
        NavigationStack {
            Text("")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    Task {
                        await authManager.signOut()
                    }
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
        }
    }
}
