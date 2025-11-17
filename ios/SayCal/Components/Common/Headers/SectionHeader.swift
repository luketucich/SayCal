import SwiftUI

/// Standardized header component with title and subtitle
/// Used across onboarding, auth, and other views for consistent styling
struct SectionHeader: View {
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

// Alias for backward compatibility with onboarding
typealias OnboardingHeader = SectionHeader

#Preview {
    SectionHeader(
        title: "Sample Title",
        subtitle: "This is a sample subtitle"
    )
    .padding()
    .background(Color(UIColor.systemBackground))
}
