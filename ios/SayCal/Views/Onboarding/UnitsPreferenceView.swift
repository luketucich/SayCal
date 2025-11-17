import SwiftUI

/// Step 1: Units preference selection
struct UnitsPreferenceView: View {
    @ObservedObject var state: OnboardingState

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose your units")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(Color(UIColor.label))

                        Text("Select your preferred measurement system")
                            .font(.system(size: 15))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                    .padding(.top, 24)
                    
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
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color(UIColor.systemGray5))
                
                HStack {
                    Spacer()
                    
                    Button {
                        state.nextStep()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.label))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// Custom unit selection card
struct UnitCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(UIColor.label))

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                
                Spacer()
                
                Circle()
                    .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray4), lineWidth: isSelected ? 2 : 1.5)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color(UIColor.label))
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        UnitsPreferenceView(state: OnboardingState())
    }
}
