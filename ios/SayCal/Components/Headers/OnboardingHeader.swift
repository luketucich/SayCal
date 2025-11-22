import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.display)
                .foregroundColor(Theme.Colors.label)

            Text(subtitle)
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .padding(.top, Theme.Spacing.xl)
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
