import SwiftUI

struct WelcomeView: View {
    @State private var showEmailAuth = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            AppColors.lightBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    Text("welcome.")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .padding(.bottom, AppSpacing.xs)

                    Text("Track your nutrition, effortlessly.")
                        .font(AppTypography.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxxl)

                VStack(spacing: AppSpacing.md) {
                    AppleAuthButton()

                    GoogleAuthButton()

                    Button {
                        HapticManager.shared.light()
                        showEmailAuth = true
                    } label: {
                        Text("Use email instead")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(.top, AppSpacing.xs)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxxl)
            }
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
        }
    }
}

#Preview("Light Mode") {
    WelcomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    WelcomeView()
        .preferredColorScheme(.dark)
}
