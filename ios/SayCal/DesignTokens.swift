//
//  DesignTokens.swift
//  SayCal
//
//  Centralized design system constants for consistent styling
//

import SwiftUI

/// Design tokens for consistent styling across the app
enum DesignTokens {

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    // MARK: - Button Heights
    enum ButtonHeight {
        static let standard: CGFloat = 48
        static let pill: CGFloat = 44
        static let auth: CGFloat = 56
    }

    // MARK: - Stroke Widths
    enum StrokeWidth {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 1.5
        static let thick: CGFloat = 2
    }

    // MARK: - Animation Durations
    enum AnimationDuration {
        static let fast: Double = 0.2
        static let normal: Double = 0.25
        static let slow: Double = 0.3
    }

    // MARK: - Shadow
    enum Shadow {
        static let small = ShadowStyle(radius: 12, y: 6, opacity: 0.1)
        static let medium = ShadowStyle(radius: 20, y: 10, opacity: 0.1)
        static let large = ShadowStyle(radius: 20, y: 6, opacity: 0.15)
    }

    struct ShadowStyle {
        let radius: CGFloat
        let y: CGFloat
        let opacity: Double
    }

    // MARK: - Opacity
    enum Opacity {
        static let veryLight: Double = 0.1
        static let light: Double = 0.2
        static let medium: Double = 0.4
        static let strong: Double = 0.6
        static let veryStrong: Double = 0.8
    }

    // MARK: - Font Sizes
    enum FontSize {
        static let small: CGFloat = 13
        static let body: CGFloat = 15
        static let bodyLarge: CGFloat = 16
        static let label: CGFloat = 14
        static let subtitle: CGFloat = 15
        static let header: CGFloat = 26
        static let largeTitle: CGFloat = 36
    }
}

// MARK: - View Extensions for Easy Access
extension View {
    func standardButtonHeight() -> some View {
        self.frame(height: DesignTokens.ButtonHeight.standard)
    }

    func authButtonHeight() -> some View {
        self.frame(height: DesignTokens.ButtonHeight.auth)
    }

    func pillButtonHeight() -> some View {
        self.frame(height: DesignTokens.ButtonHeight.pill)
    }

    func standardCornerRadius() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.medium)
    }

    func smallCornerRadius() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.small)
    }

    func largeCornerRadius() -> some View {
        self.cornerRadius(DesignTokens.CornerRadius.large)
    }

    func standardShadow() -> some View {
        let shadow = DesignTokens.Shadow.medium
        return self.shadow(
            color: Color.black.opacity(shadow.opacity),
            radius: shadow.radius,
            y: shadow.y
        )
    }

    func smallShadow() -> some View {
        let shadow = DesignTokens.Shadow.small
        return self.shadow(
            color: Color.black.opacity(shadow.opacity),
            radius: shadow.radius,
            y: shadow.y
        )
    }
}
