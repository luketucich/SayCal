//
//  DesignSystem.swift
//  SayCal
//
//  Design System Constants based on Fuse design patterns
//

import SwiftUI

// MARK: - Colors
extension Color {
    // MARK: Primary Colors
    static let primaryPurple = Color(red: 138/255, green: 99/255, blue: 210/255) // #8A63D2
    static let primaryBlue = Color(red: 59/255, green: 130/255, blue: 246/255) // #3B82F6
    static let primaryGreen = Color(red: 34/255, green: 197/255, blue: 94/255) // #22C55E

    // MARK: Background Colors
    static let backgroundPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.0, alpha: 1.0) : UIColor(white: 1.0, alpha: 1.0)
    })

    static let backgroundSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.11, alpha: 1.0) : UIColor(white: 0.98, alpha: 1.0)
    })

    static let backgroundTertiary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.17, alpha: 1.0) : UIColor(white: 0.95, alpha: 1.0)
    })

    // MARK: Card Colors
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.14, alpha: 1.0) : UIColor.white
    })

    static let cardBackgroundElevated = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.17, alpha: 1.0) : UIColor.white
    })

    // MARK: Text Colors
    static let textPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })

    static let textSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.7, alpha: 1.0) : UIColor(white: 0.4, alpha: 1.0)
    })

    static let textTertiary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.5, alpha: 1.0) : UIColor(white: 0.6, alpha: 1.0)
    })

    // MARK: Border Colors
    static let borderPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.25, alpha: 1.0) : UIColor(white: 0.9, alpha: 1.0)
    })

    static let borderSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.2, alpha: 1.0) : UIColor(white: 0.85, alpha: 1.0)
    })

    // MARK: Button Colors
    static let buttonPrimary = Color.black
    static let buttonPrimaryText = Color.white
    static let buttonSecondary = Color.clear
    static let buttonSecondaryBorder = Color.borderPrimary

    // MARK: Status Colors
    static let statusSuccess = primaryGreen
    static let statusError = Color.red
    static let statusWarning = Color.orange
    static let statusInfo = primaryBlue
}

// MARK: - Typography
struct DSTypography {
    // MARK: Display
    static let displayLarge = Font.system(size: 48, weight: .bold)
    static let displayMedium = Font.system(size: 36, weight: .bold)
    static let displaySmall = Font.system(size: 30, weight: .bold)

    // MARK: Title
    static let titleLarge = Font.system(size: 28, weight: .bold)
    static let titleMedium = Font.system(size: 22, weight: .semibold)
    static let titleSmall = Font.system(size: 18, weight: .semibold)

    // MARK: Heading
    static let headingLarge = Font.system(size: 20, weight: .semibold)
    static let headingMedium = Font.system(size: 17, weight: .semibold)
    static let headingSmall = Font.system(size: 15, weight: .semibold)

    // MARK: Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)

    // MARK: Label
    static let labelLarge = Font.system(size: 15, weight: .medium)
    static let labelMedium = Font.system(size: 13, weight: .medium)
    static let labelSmall = Font.system(size: 11, weight: .medium)

    // MARK: Caption
    static let captionLarge = Font.system(size: 13, weight: .regular)
    static let captionMedium = Font.system(size: 12, weight: .regular)
    static let captionSmall = Font.system(size: 11, weight: .regular)

    // MARK: Button
    static let buttonLarge = Font.system(size: 17, weight: .semibold)
    static let buttonMedium = Font.system(size: 15, weight: .semibold)
    static let buttonSmall = Font.system(size: 13, weight: .semibold)
}

// MARK: - Spacing
struct DSSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let xxxxl: CGFloat = 48
}

// MARK: - Corner Radius
struct DSRadius {
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Border Width
struct DSBorder {
    static let thin: CGFloat = 0.5
    static let medium: CGFloat = 1
    static let thick: CGFloat = 2
    static let extraThick: CGFloat = 3
}

// MARK: - Shadows
struct DSShadow {
    static func small(colorScheme: ColorScheme) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        let color = colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        return (color: color, radius: 4, x: 0, y: 2)
    }

    static func medium(colorScheme: ColorScheme) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        let color = colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.15)
        return (color: color, radius: 8, x: 0, y: 4)
    }

    static func large(colorScheme: ColorScheme) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        let color = colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.2)
        return (color: color, radius: 16, x: 0, y: 8)
    }
}

// MARK: - Size Constants
struct DSSize {
    // MARK: Button Heights
    static let buttonSmall: CGFloat = 40
    static let buttonMedium: CGFloat = 48
    static let buttonLarge: CGFloat = 56

    // MARK: Input Heights
    static let inputSmall: CGFloat = 40
    static let inputMedium: CGFloat = 48
    static let inputLarge: CGFloat = 56

    // MARK: Icon Sizes
    static let iconXS: CGFloat = 16
    static let iconSM: CGFloat = 20
    static let iconMD: CGFloat = 24
    static let iconLG: CGFloat = 32
    static let iconXL: CGFloat = 40
    static let iconXXL: CGFloat = 48
}

// MARK: - View Modifiers

// Card Style
struct DSCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(elevated ? Color.cardBackgroundElevated : Color.cardBackground)
            .cornerRadius(DSRadius.md)
            .shadow(
                color: DSShadow.medium(colorScheme: colorScheme).color,
                radius: DSShadow.medium(colorScheme: colorScheme).radius,
                x: DSShadow.medium(colorScheme: colorScheme).x,
                y: DSShadow.medium(colorScheme: colorScheme).y
            )
    }
}

// Primary Button Style
struct DSPrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.buttonLarge)
            .foregroundColor(Color.buttonPrimaryText)
            .frame(maxWidth: .infinity)
            .frame(height: DSSize.buttonLarge)
            .background(disabled ? Color.textTertiary : Color.buttonPrimary)
            .cornerRadius(DSRadius.md)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(disabled ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Secondary Button Style
struct DSSecondaryButtonStyle: ButtonStyle {
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.buttonLarge)
            .foregroundColor(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DSSize.buttonLarge)
            .background(Color.buttonSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(Color.buttonSecondaryBorder, lineWidth: DSBorder.medium)
            )
            .cornerRadius(DSRadius.md)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(disabled ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Input Field Style
struct DSInputFieldStyle: ViewModifier {
    var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .font(DSTypography.bodyLarge)
            .padding(.horizontal, DSSpacing.md)
            .frame(height: DSSize.inputMedium)
            .background(Color.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(isFocused ? Color.primaryBlue : Color.borderPrimary, lineWidth: isFocused ? DSBorder.thick : DSBorder.medium)
            )
            .cornerRadius(DSRadius.md)
    }
}

// MARK: - View Extensions
extension View {
    func dsCard(elevated: Bool = false) -> some View {
        self.modifier(DSCard(elevated: elevated))
    }

    func dsInputField(isFocused: Bool = false) -> some View {
        self.modifier(DSInputFieldStyle(isFocused: isFocused))
    }
}

// MARK: - Animation Presets
struct DSAnimation {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let snappy = Animation.snappy(duration: 0.25)
}
