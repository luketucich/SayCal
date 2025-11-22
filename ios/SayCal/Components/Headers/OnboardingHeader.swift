import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text(title)
                .font(DesignSystem.Typography.displayMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Text(subtitle)
                .font(DesignSystem.Typography.bodyLarge)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(.top, DesignSystem.Spacing.xxlarge)
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
