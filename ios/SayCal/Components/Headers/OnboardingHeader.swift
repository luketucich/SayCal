import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xSmall) {
            Text(title)
                .font(DS.Typography.title2(weight: .bold))
                .foregroundColor(DS.Colors.label)

            Text(subtitle)
                .font(DS.Typography.subheadline())
                .foregroundColor(DS.Colors.secondaryLabel)
        }
        .padding(.top, DS.Spacing.xLarge)
    }
}

#Preview {
    OnboardingHeader(
        title: "Sample Title",
        subtitle: "This is a sample subtitle for the onboarding screen"
    )
    .padding(DS.Spacing.large)
    .background(DS.Colors.background)
}
