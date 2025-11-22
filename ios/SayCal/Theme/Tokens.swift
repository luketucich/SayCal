import SwiftUI

// MARK: - Design Tokens
// Centralized design tokens for the entire application
// Modern, consistent, and easy to maintain

// MARK: - Colors

extension Color {
    // MARK: Background Colors
    static let appBackground = Color(red: 0.96, green: 0.96, blue: 0.97) // #F5F5F7
    static let cardBackground = Color.white
    static let cardBackgroundDark = Color(red: 0.17, green: 0.17, blue: 0.18) // #2B2B2D
    static let inputBackground = Color(uiColor: .systemBackground)
    static let overlayBackground = Color(uiColor: .secondarySystemBackground)

    // MARK: Text Colors
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let textTertiary = Color(uiColor: .tertiaryLabel)
    static let textDisabled = Color(uiColor: .systemGray3)

    // MARK: Accent & Brand Colors
    static let accent = Color(red: 0.4, green: 0.6, blue: 0.9) // Blue accent
    static let accentLight = Color(red: 0.6, green: 0.75, blue: 0.95)

    // MARK: Semantic Colors
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange
    static let info = Color.blue

    // MARK: Macro Colors
    static let macroCarbs = Color.blue
    static let macroFats = Color.orange
    static let macroProtein = Color.green

    // MARK: Border & Divider Colors
    static let border = Color(uiColor: .systemGray5)
    static let borderActive = Color(uiColor: .label)
    static let borderSubtle = Color(uiColor: .systemGray4)
    static let divider = Color(uiColor: .separator)

    // MARK: State Colors
    static let recording = Color.red
    static let processing = Color.blue
    static let completed = Color.green
}

// MARK: - Typography

extension Font {
    // MARK: Display
    static let displayHero = Font.system(size: 48, weight: .bold)
    static let displayLarge = Font.system(size: 36, weight: .bold, design: .rounded)

    // MARK: Titles
    static let titleLarge = Font.system(size: 32, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 24, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)

    // MARK: Body
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 17, weight: .medium)
    static let bodySemibold = Font.system(size: 17, weight: .semibold)
    static let bodyBold = Font.system(size: 17, weight: .bold)

    // MARK: Captions
    static let caption = Font.system(size: 15, weight: .regular)
    static let captionMedium = Font.system(size: 15, weight: .medium)
    static let captionSemibold = Font.system(size: 15, weight: .semibold)

    static let smallCaption = Font.system(size: 13, weight: .regular)
    static let smallCaptionMedium = Font.system(size: 13, weight: .medium)
    static let smallCaptionSemibold = Font.system(size: 13, weight: .semibold)

    // MARK: Icons
    static let icon = Font.system(size: 14, weight: .medium)
    static let iconSemibold = Font.system(size: 14, weight: .semibold)
    static let iconBold = Font.system(size: 14, weight: .bold)
    static let iconSmall = Font.system(size: 12, weight: .semibold)
    static let iconLarge = Font.system(size: 20, weight: .semibold)
}

// MARK: - Spacing

enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 6
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 40
}

// MARK: - Corner Radius

enum CornerRadius {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let pill: CGFloat = 100

    // Special cases
    static let progress: CGFloat = 3
}

// MARK: - Dimensions

enum Dimensions {
    // MARK: Button Heights
    static let buttonHeightLarge: CGFloat = 56
    static let buttonHeightMedium: CGFloat = 52
    static let buttonHeightSmall: CGFloat = 48

    // MARK: Input Heights
    static let inputHeight: CGFloat = 56
    static let inputHeightSmall: CGFloat = 52
    static let codeInputWidth: CGFloat = 48

    // MARK: Icon Sizes
    static let iconXSmall: CGFloat = 8
    static let iconSmall: CGFloat = 10
    static let iconMedium: CGFloat = 12
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32
    static let iconHuge: CGFloat = 40

    // MARK: Radio & Checkboxes
    static let radioOuter: CGFloat = 24
    static let radioInner: CGFloat = 12

    // MARK: Component Specific
    static let pickerHeight: CGFloat = 200
    static let progressBarHeight: CGFloat = 6
    static let tabIndicatorHeight: CGFloat = 3
    static let chartSize: CGFloat = 200
    static let pieChartSize: CGFloat = 220

    // MARK: Recording Button
    static let recordingButtonIdle: CGFloat = 72
    static let recordingButtonActive: CGFloat = 88
    static let recordingIconIdle: CGFloat = 28
    static let recordingIconActive: CGFloat = 32
}

// MARK: - Opacity

enum Opacity {
    static let invisible: Double = 0.01
    static let subtle: Double = 0.1
    static let light: Double = 0.15
    static let medium: Double = 0.2
    static let visible: Double = 0.3
    static let semitransparent: Double = 0.5
    static let strong: Double = 0.8
    static let veryStrong: Double = 0.9

    // Shadow specific
    static let shadowLight: Double = 0.08
    static let shadowMedium: Double = 0.1
    static let shadowStrong: Double = 0.12
}

// MARK: - Line Width

enum LineWidth {
    static let thin: CGFloat = 1.0
    static let regular: CGFloat = 1.5
    static let thick: CGFloat = 2.0
    static let chartStroke: CGFloat = 20.0
}

// MARK: - Shadows

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum Shadows {
    static let small = ShadowStyle(
        color: Color.black.opacity(Opacity.shadowLight),
        radius: 4,
        x: 0,
        y: 2
    )

    static let medium = ShadowStyle(
        color: Color.black.opacity(Opacity.shadowMedium),
        radius: 8,
        x: 0,
        y: 4
    )

    static let large = ShadowStyle(
        color: Color.black.opacity(Opacity.shadowStrong),
        radius: 16,
        x: 0,
        y: 8
    )
}

// MARK: - Animation

enum Animation {
    static let quick = SwiftUI.Animation.easeInOut(duration: 0.1)
    static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
    static let smooth = SwiftUI.Animation.easeInOut(duration: 0.4)
    static let pulse = SwiftUI.Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)

    static let springResponsive = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let springSmooth = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let springBouncy = SwiftUI.Animation.spring(response: 0.8, dampingFraction: 0.75)
}
