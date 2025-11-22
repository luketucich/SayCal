import SwiftUI

// MARK: - Design System

struct DesignSystem {

    // MARK: - Colors

    struct Colors {
        // Modern gradient colors
        static let primaryGradient = [
            Color(red: 0.4, green: 0.3, blue: 0.9),  // Deep purple
            Color(red: 0.6, green: 0.4, blue: 1.0)   // Vibrant purple
        ]

        static let accentGradient = [
            Color(red: 0.2, green: 0.7, blue: 0.9),  // Cyan
            Color(red: 0.4, green: 0.5, blue: 1.0)   // Blue
        ]

        static let warmGradient = [
            Color(red: 1.0, green: 0.4, blue: 0.5),  // Coral
            Color(red: 1.0, green: 0.6, blue: 0.3)   // Orange
        ]

        static let successGradient = [
            Color(red: 0.2, green: 0.8, blue: 0.6),  // Mint
            Color(red: 0.3, green: 0.9, blue: 0.5)   // Green
        ]

        // Background gradients for welcome screen
        static let welcomeGradientLight = [
            Color(red: 0.95, green: 0.92, blue: 1.0),   // Soft lavender
            Color(red: 0.92, green: 0.95, blue: 1.0),   // Soft blue
            Color(red: 0.98, green: 0.94, blue: 0.96)   // Soft pink
        ]

        static let welcomeGradientDark = [
            Color(red: 0.08, green: 0.05, blue: 0.15),  // Deep purple
            Color(red: 0.05, green: 0.08, blue: 0.18),  // Deep blue
            Color(red: 0.1, green: 0.06, blue: 0.12)    // Deep plum
        ]

        // Semantic colors
        static var primary: Color {
            Color(red: 0.5, green: 0.35, blue: 0.95)
        }

        static var accent: Color {
            Color(red: 0.3, green: 0.6, blue: 1.0)
        }

        static var success: Color {
            Color(red: 0.25, green: 0.85, blue: 0.55)
        }

        static var warning: Color {
            Color(red: 1.0, green: 0.6, blue: 0.3)
        }

        static var error: Color {
            Color(red: 1.0, green: 0.3, blue: 0.4)
        }

        // Adaptive surface colors
        static var surface: Color {
            Color(UIColor.systemBackground)
        }

        static var surfaceSecondary: Color {
            Color(UIColor.secondarySystemBackground)
        }

        static var surfaceTertiary: Color {
            Color(UIColor.tertiarySystemBackground)
        }

        // Text colors
        static var textPrimary: Color {
            Color(UIColor.label)
        }

        static var textSecondary: Color {
            Color(UIColor.secondaryLabel)
        }

        static var textTertiary: Color {
            Color(UIColor.tertiaryLabel)
        }

        // Border colors
        static var border: Color {
            Color(UIColor.separator)
        }

        static var borderSubtle: Color {
            Color(UIColor.systemGray5)
        }
    }

    // MARK: - Typography

    struct Typography {
        // Display styles
        static func largeTitle(weight: Font.Weight = .bold) -> Font {
            .system(size: 34, weight: weight)
        }

        static func title1(weight: Font.Weight = .bold) -> Font {
            .system(size: 28, weight: weight)
        }

        static func title2(weight: Font.Weight = .semibold) -> Font {
            .system(size: 22, weight: weight)
        }

        static func title3(weight: Font.Weight = .semibold) -> Font {
            .system(size: 20, weight: weight)
        }

        // Body styles
        static func headline(weight: Font.Weight = .semibold) -> Font {
            .system(size: 17, weight: weight)
        }

        static func body(weight: Font.Weight = .regular) -> Font {
            .system(size: 17, weight: weight)
        }

        static func callout(weight: Font.Weight = .regular) -> Font {
            .system(size: 16, weight: weight)
        }

        static func subheadline(weight: Font.Weight = .regular) -> Font {
            .system(size: 15, weight: weight)
        }

        static func footnote(weight: Font.Weight = .regular) -> Font {
            .system(size: 13, weight: weight)
        }

        static func caption1(weight: Font.Weight = .regular) -> Font {
            .system(size: 12, weight: weight)
        }

        static func caption2(weight: Font.Weight = .regular) -> Font {
            .system(size: 11, weight: weight)
        }
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows

    struct Shadows {
        static func small(color: Color = Color.black.opacity(0.08)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 4, x: 0, y: 2)
        }

        static func medium(color: Color = Color.black.opacity(0.12)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 8, x: 0, y: 4)
        }

        static func large(color: Color = Color.black.opacity(0.15)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 16, x: 0, y: 8)
        }

        static func glow(color: Color, radius: CGFloat = 20) -> some View {
            EmptyView()
                .shadow(color: color.opacity(0.5), radius: radius, x: 0, y: 0)
        }
    }

    // MARK: - Animations

    struct Animations {
        static let quick = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let smooth = Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
        static let gentle = Animation.easeInOut(duration: 0.3)
        static let fast = Animation.easeInOut(duration: 0.2)
    }
}

// MARK: - View Extensions

extension View {
    // Apply card style
    func cardStyle(
        backgroundColor: Color = DesignSystem.Colors.surface,
        borderColor: Color = DesignSystem.Colors.borderSubtle,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        padding: CGFloat = DesignSystem.Spacing.lg
    ) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
    }

    // Apply gradient background
    func gradientBackground(_ colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> some View {
        self.background(
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
    }

    // Apply glassmorphic effect
    func glassEffect(cornerRadius: CGFloat = DesignSystem.CornerRadius.lg) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
    }

    // Apply modern shadow
    func modernShadow(size: String = "medium") -> some View {
        switch size {
        case "small":
            return AnyView(self.shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2))
        case "large":
            return AnyView(self.shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8))
        default:
            return AnyView(self.shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4))
        }
    }

    // Shimmer effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.3),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}
