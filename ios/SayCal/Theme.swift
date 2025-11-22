import SwiftUI

// MARK: - Design System
// Centralized theme configuration inspired by bold, minimal apps like Stoic and Cal AI
// Easy to customize - change accent color in one place

struct Theme {
    // MARK: - Colors

    struct Colors {
        // MARK: Accent & Brand
        // Change this to update the entire app's accent color
        static let accent = Color(red: 139/255, green: 92/255, blue: 246/255) // Purple #8B5CF6
        static let accentLight = accent.opacity(0.15)
        static let accentMuted = accent.opacity(0.6)

        // MARK: Semantic Colors
        static let success = Color.green
        static let successLight = Color.green.opacity(0.15)
        static let warning = Color.orange
        static let warningLight = Color.orange.opacity(0.15)
        static let error = Color.red
        static let errorLight = Color.red.opacity(0.15)
        static let info = Color.blue
        static let infoLight = Color.blue.opacity(0.15)

        // MARK: Macros (Nutrition)
        static let carbs = Color.blue
        static let protein = Color.green
        static let fats = Color.orange

        // MARK: Adaptive System Colors (Auto Dark Mode)
        static let label = Color(UIColor.label)
        static let secondaryLabel = Color(UIColor.secondaryLabel)
        static let tertiaryLabel = Color(UIColor.tertiaryLabel)

        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)

        static let groupedBackground = Color(UIColor.systemGroupedBackground)
        static let secondaryGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)

        static let separator = Color(UIColor.separator)
        static let border = Color(UIColor.systemGray4)
        static let borderLight = Color(UIColor.systemGray5)

        // MARK: Helper for dynamic colors
        static func adaptiveGray(light: UIColor, dark: UIColor) -> Color {
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            })
        }
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let small: CGFloat = 8      // Pills, small buttons
        static let medium: CGFloat = 12    // Cards, inputs, standard buttons
        static let large: CGFloat = 16     // Modals, overlays
        static let extraLarge: CGFloat = 24 // Special elements
        static let capsule: CGFloat = 999  // Fully rounded pills
    }

    // MARK: - Shadows

    struct Shadows {
        // Subtle elevation for cards
        static let subtle = ShadowConfig(
            color: Color.black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 2
        )

        // Medium elevation for interactive elements
        static let medium = ShadowConfig(
            color: Color.black.opacity(0.1),
            radius: 12,
            x: 0,
            y: 4
        )

        // Bold elevation for primary actions
        static let bold = ShadowConfig(
            color: Color.black.opacity(0.15),
            radius: 20,
            x: 0,
            y: 8
        )

        // Accent glow for emphasis
        static let accentGlow = ShadowConfig(
            color: Colors.accent.opacity(0.3),
            radius: 16,
            x: 0,
            y: 4
        )
    }

    struct ShadowConfig {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Spacing

    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }

    // MARK: - Typography

    struct Typography {
        // Display - Large headers
        static let display = Font.system(size: 32, weight: .bold)
        static let displaySize: CGFloat = 32

        // Title - Section headers
        static let title = Font.system(size: 24, weight: .semibold)
        static let titleSize: CGFloat = 24

        // Title 2 - Sub-headers
        static let title2 = Font.system(size: 20, weight: .semibold)
        static let title2Size: CGFloat = 20

        // Headline - Emphasized content
        static let headline = Font.system(size: 18, weight: .semibold)
        static let headlineSize: CGFloat = 18

        // Body - Standard text
        static let body = Font.system(size: 16, weight: .regular)
        static let bodySize: CGFloat = 16

        // Callout - Secondary content
        static let callout = Font.system(size: 15, weight: .regular)
        static let calloutSize: CGFloat = 15

        // Caption - Helper text
        static let caption = Font.system(size: 14, weight: .regular)
        static let captionSize: CGFloat = 14

        // Caption (Medium weight)
        static let captionMedium = Font.system(size: 14, weight: .medium)

        // Small - Tiny text
        static let small = Font.system(size: 12, weight: .regular)
        static let smallSize: CGFloat = 12

        // Numbers (rounded design)
        static func number(size: CGFloat, weight: Font.Weight = .regular) -> Font {
            Font.system(size: size, weight: weight, design: .rounded)
        }
    }

    // MARK: - Button Sizes

    struct ButtonSize {
        static let standard: CGFloat = 48
        static let large: CGFloat = 56
        static let compact: CGFloat = 40
    }

    // MARK: - Border Width

    struct BorderWidth {
        static let thin: CGFloat = 1
        static let standard: CGFloat = 1.5
        static let thick: CGFloat = 2
    }
}

// MARK: - View Modifiers

extension View {
    // MARK: Shadow Modifiers

    func cardShadow() -> some View {
        let shadow = Theme.Shadows.subtle
        return self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }

    func mediumShadow() -> some View {
        let shadow = Theme.Shadows.medium
        return self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }

    func boldShadow() -> some View {
        let shadow = Theme.Shadows.bold
        return self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }

    func accentGlowShadow() -> some View {
        let shadow = Theme.Shadows.accentGlow
        return self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }

    // MARK: Card Styles

    func cardStyle(padding: CGFloat = Theme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .cardShadow()
    }

    func selectableCardStyle(isSelected: Bool, padding: CGFloat = Theme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(isSelected ? Theme.Colors.accentLight : Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.border, lineWidth: isSelected ? Theme.BorderWidth.thick : Theme.BorderWidth.thin)
            )
            .cardShadow()
    }

    // MARK: Button Styles

    func primaryButtonStyle() -> some View {
        self
            .frame(height: Theme.ButtonSize.standard)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.accent)
            .foregroundColor(.white)
            .cornerRadius(Theme.CornerRadius.medium)
            .font(Theme.Typography.headline)
            .mediumShadow()
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(height: Theme.ButtonSize.standard)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.background)
            .foregroundColor(Theme.Colors.label)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.standard)
            )
            .font(Theme.Typography.headline)
            .cardShadow()
    }

    // MARK: Input Styles

    func inputFieldStyle() -> some View {
        self
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.border, lineWidth: Theme.BorderWidth.thin)
            )
            .cardShadow()
    }

    // MARK: Section Styles

    func sectionHeaderStyle() -> some View {
        self
            .font(Theme.Typography.captionMedium)
            .foregroundColor(Theme.Colors.secondaryLabel)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}
