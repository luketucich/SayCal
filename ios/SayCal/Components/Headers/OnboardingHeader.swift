import SwiftUI

struct OnboardingHeader: View {
    let title: String
    let subtitle: String
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.title1(weight: .bold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -10)

            Text(subtitle)
                .font(DesignSystem.Typography.body(weight: .regular))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -10)
        }
        .padding(.top, DesignSystem.Spacing.xl)
        .onAppear {
            withAnimation(DesignSystem.Animations.smooth) {
                animate = true
            }
        }
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
