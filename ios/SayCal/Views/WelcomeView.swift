import SwiftUI

struct WelcomeView: View {
    @State private var showOnboarding = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.12, blue: 0.15)
                ] : [
                    Color(red: 0.95, green: 0.85, blue: 0.95),
                    Color(red: 0.85, green: 0.90, blue: 1.0),
                    Color(red: 0.95, green: 0.90, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Welcome text
                VStack(spacing: 8) {
                    Text("SayCal")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Quick. Accurate. Simple.")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: colorScheme == .dark ?
                                    [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.7, green: 0.5, blue: 1.0)] :
                                    [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    showOnboarding = true
                }) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            AuthSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(.systemBackground))
        }
    }
}

#Preview("Light Mode") {
    WelcomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    WelcomeView()
        .preferredColorScheme(.dark)
}
