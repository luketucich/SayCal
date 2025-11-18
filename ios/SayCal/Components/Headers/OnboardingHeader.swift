// Standardized header component for onboarding screens

import SwiftUI

// Header with title and subtitle
struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(Color(UIColor.label))

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.top, 24)
    }
}

#Preview {
    OnboardingHeader(
        title: "Sample Title",
        subtitle: "This is a sample subtitle for the onboarding screen"
    )
    .padding()
    .background(Color(UIColor.systemBackground))
}
