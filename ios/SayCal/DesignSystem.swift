import SwiftUI

// MARK: - Design System
// Based on modern wellness app design (Stoic-inspired aesthetic)

struct AppColors {
    // MARK: - Background Colors
    static let lightBackground = Color(red: 0.96, green: 0.96, blue: 0.97) // #F5F5F7
    static let darkCardBackground = Color(red: 0.17, green: 0.17, blue: 0.18) // #2B2B2D
    static let lightCardBackground = Color.white

    // MARK: - Text Colors
    static let primaryText = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
    static let tertiaryText = Color(UIColor.tertiaryLabel)

    // MARK: - Accent Colors
    static let accent = Color(red: 0.4, green: 0.6, blue: 0.9) // Blue accent
    static let accentLight = Color(red: 0.6, green: 0.75, blue: 0.95)

    // MARK: - Semantic Colors
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange
}

struct AppTypography {
    // MARK: - Display
    static let displayLarge = Font.system(size: 36, weight: .bold, design: .rounded)

    // MARK: - Headers
    static let largeTitle = Font.system(size: 32, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 24, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // MARK: - Body
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 17, weight: .medium)
    static let bodySemibold = Font.system(size: 17, weight: .semibold)

    // MARK: - Captions
    static let caption = Font.system(size: 15, weight: .regular)
    static let captionMedium = Font.system(size: 15, weight: .medium)
    static let smallCaption = Font.system(size: 13, weight: .regular)
    static let smallCaptionMedium = Font.system(size: 13, weight: .medium)
}

struct AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}

struct AppCornerRadius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let pill: CGFloat = 100 // For pill-shaped buttons
}

struct AppShadow {
    static let small = Shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - View Extensions

extension View {
    func appBackground() -> some View {
        self.background(AppColors.lightBackground)
    }

    func cardStyle(darkMode: Bool = false) -> some View {
        self
            .background(darkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground)
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: AppShadow.medium.color, radius: AppShadow.medium.radius, x: AppShadow.medium.x, y: AppShadow.medium.y)
    }

    func pillButtonStyle(filled: Bool = true) -> some View {
        self
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.md)
            .background(filled ? AppColors.primaryText : Color.clear)
            .foregroundColor(filled ? Color(UIColor.systemBackground) : AppColors.primaryText)
            .cornerRadius(AppCornerRadius.pill)
    }
}
