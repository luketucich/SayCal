import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.system(size: DesignTokens.FontSize.header, weight: .semibold))
                .foregroundColor(Color(UIColor.label))

            Text(subtitle)
                .font(.system(size: DesignTokens.FontSize.body))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.top, DesignTokens.Spacing.xl)
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
