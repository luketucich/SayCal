import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title)
                .font(DSTypography.titleLarge)
                .foregroundColor(Color.textPrimary)

            Text(subtitle)
                .font(DSTypography.bodyMedium)
                .foregroundColor(Color.textSecondary)
        }
        .padding(.top, DSSpacing.xl)
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
