// Onboarding step for selecting unit preference (metric or imperial)

import SwiftUI

// Onboarding step 1: Metric vs Imperial
struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    OnboardingHeader(
                        title: "Choose your units",
                        subtitle: "Select your preferred measurement system"
                    )
                    
                    // Selection cards
                    VStack(spacing: 12) {
                        UnitCard(
                            title: "Metric",
                            subtitle: "Kilograms • Centimeters",
                            isSelected: state.unitsPreference == .metric
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                state.unitsPreference = .metric
                            }
                        }
                        
                        UnitCard(
                            title: "Imperial",
                            subtitle: "Pounds • Feet & Inches",
                            isSelected: state.unitsPreference == .imperial
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                state.unitsPreference = .imperial
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom button area
            OnboardingBottomBar(
                showBackButton: false,
                onNext: { state.nextStep() }
            )
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
