import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String
    let useLowercaseTitle: Bool

    init(title: String, subtitle: String, useLowercaseTitle: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.useLowercaseTitle = useLowercaseTitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(useLowercaseTitle ? title.lowercased() + "." : title)
                .font(.title1)
                .foregroundColor(.textPrimary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(.top, Spacing.xxl)
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
