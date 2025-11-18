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
                DailyStreakTracker()
                    .padding()
                
                Spacer()
                
                chart.frame(width: 200, height: 200)
                    .padding(.bottom, 450)
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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let profile = authManager.cachedProfile {
                        // User Info Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User Info")
                                .font(.headline)
                            Text("User ID: \(profile.userId.uuidString)")
                            Text("Sex: \(profile.sex.rawValue.capitalized)")
                            Text("Age: \(profile.age)")
                        }
                        
                        Divider()
                        
                        // Units & Measurements
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Measurements")
                                .font(.headline)
                            Text("Units: \(profile.unitsPreference.rawValue.capitalized)")
                            
                            // Display height according to unit preference
                            if profile.unitsPreference == .imperial {
                                let (feet, inches) = profile.heightCm.cmToFeetAndInches
                                Text("Height: \(feet)' \(inches)\"")
                            } else {
                                Text("Height: \(profile.heightCm) cm")
                            }
                            
                            // Display weight according to unit preference
                            if profile.unitsPreference == .imperial {
                                let lbs = profile.weightKg.kgToLbs
                                Text("Weight: \(lbs, specifier: "%.1f") lbs")
                            } else {
                                Text("Weight: \(profile.weightKg, specifier: "%.1f") kg")
                            }
                        }
                        
                        Divider()
                        
                        // Activity & Goals
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity & Goals")
                                .font(.headline)
                            Text("Activity Level: \(profile.activityLevel.rawValue)")
                            Text("Goal: \(profile.goal.rawValue)")
                            Text("Target Calories: \(profile.targetCalories)")
                        }
                        
                        Divider()
                        
                        // Dietary Preferences
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dietary Preferences")
                                .font(.headline)
                            if let preferences = profile.dietaryPreferences, !preferences.isEmpty {
                                ForEach(preferences, id: \.self) { preference in
                                    Text("• \(preference)")
                                }
                            } else {
                                Text("None")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Allergies
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allergies")
                                .font(.headline)
                            if let allergies = profile.allergies, !allergies.isEmpty {
                                ForEach(allergies, id: \.self) { allergy in
                                    Text("• \(allergy)")
                                }
                            } else {
                                Text("None")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        // Metadata
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Account Info")
                                .font(.headline)
                            Text("Onboarding Completed: \(profile.onboardingCompleted ? "Yes" : "No")")
                            if let createdAt = profile.createdAt {
                                Text("Created: \(createdAt.formatted(date: .abbreviated, time: .shortened))")
                            }
                            if let updatedAt = profile.updatedAt {
                                Text("Updated: \(updatedAt.formatted(date: .abbreviated, time: .shortened))")
                            }
                        }
                        
                    } else {
                        Text("No profile data available")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
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
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject({
            let manager = AuthManager()
            // Configure for preview convenience
            manager.isAuthenticated = true
            manager.isLoading = false
            manager.onboardingCompleted = true
            return manager
        }())
}
