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
        VStack(alignment: .leading, spacing: 12) {
            Text(useLowercaseTitle ? title.lowercased() + "." : title)
                .font(AppTypography.title1)
                .foregroundColor(AppColors.primaryText)

            Text(subtitle)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
                .lineSpacing(4)
        }
        .padding(.top, AppSpacing.xl)
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
