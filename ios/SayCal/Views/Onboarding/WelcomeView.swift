import SwiftUI

struct WelcomeView: View {
    @State private var showEmailAuth = false
    @Environment(\.colorScheme) var colorScheme
    @State private var animateContent = false

    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: colorScheme == .dark
                    ? DesignSystem.Colors.welcomeGradientDark
                    : DesignSystem.Colors.welcomeGradientLight,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated floating orbs
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.primary.opacity(0.3),
                                    DesignSystem.Colors.primary.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .blur(radius: 60)
                        .offset(x: -100, y: -150)
                        .opacity(0.6)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignSystem.Colors.accent.opacity(0.25),
                                    DesignSystem.Colors.accent.opacity(0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 180
                            )
                        )
                        .frame(width: 350, height: 350)
                        .blur(radius: 50)
                        .offset(x: geometry.size.width - 150, y: geometry.size.height - 200)
                        .opacity(0.5)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // App branding
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // App icon/logo placeholder
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: DesignSystem.Colors.primaryGradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(
                                color: DesignSystem.Colors.primary.opacity(0.4),
                                radius: 20,
                                x: 0,
                                y: 10
                            )

                        Image(systemName: "fork.knife")
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateContent ? 1.0 : 0.8)
                    .opacity(animateContent ? 1.0 : 0)

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("SayCal")
                            .font(DesignSystem.Typography.largeTitle(weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Text("Track calories with your voice")
                            .font(DesignSystem.Typography.body(weight: .regular))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : 20)
                }
                .padding(.top, 100)

                Spacer()

                // Auth buttons in glassmorphic container
                VStack(spacing: DesignSystem.Spacing.lg) {
                    AppleAuthButton()

                    GoogleAuthButton()

                    Button {
                        HapticManager.shared.light()
                        showEmailAuth = true
                    } label: {
                        Text("Use email instead")
                            .font(DesignSystem.Typography.body(weight: .medium))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    .padding(.top, DesignSystem.Spacing.sm)
                }
                .padding(DesignSystem.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xxl)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xxl)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxxl)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 30)
            }
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.smooth.delay(0.2)) {
                animateContent = true
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
