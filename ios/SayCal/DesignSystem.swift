import SwiftUI

// MARK: - Design System
// Single source of truth for all design tokens in the app
// Premium, minimal aesthetic inspired by best-in-class iOS apps

enum DesignSystem {

    // MARK: - Colors
    enum Colors {
        // Primary
        static let primary = Color.black
        static let primaryText = Color.white

        // Backgrounds
        static let background = Color(UIColor.systemGroupedBackground)
        static let cardBackground = Color(UIColor.systemBackground)
        static let surfaceElevated = Color(UIColor.systemBackground)

        // Text
        static let textPrimary = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let textTertiary = Color(UIColor.tertiaryLabel)

        // Borders
        static let borderLight = Color.black.opacity(0.08)
        static let borderMedium = Color.black.opacity(0.15)
        static let borderHeavy = Color.black.opacity(0.25)

        // Shadows
        static let shadowLight = Color.black.opacity(0.04)
        static let shadowMedium = Color.black.opacity(0.08)
        static let shadowHeavy = Color.black.opacity(0.12)

        // States
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        static let info = Color.blue
    }

    // MARK: - Typography
    enum Typography {
        // Display - For main screen headers
        static let displayLarge = Font.system(size: 34, weight: .bold)
        static let displayMedium = Font.system(size: 32, weight: .bold)
        static let displaySmall = Font.system(size: 28, weight: .bold)

        // Title - For card titles and section headers
        static let titleLarge = Font.system(size: 22, weight: .bold)
        static let titleMedium = Font.system(size: 19, weight: .semibold)
        static let titleSmall = Font.system(size: 17, weight: .semibold)

        // Body - For main content text
        static let bodyLarge = Font.system(size: 17, weight: .regular)
        static let bodyMedium = Font.system(size: 16, weight: .regular)
        static let bodySmall = Font.system(size: 15, weight: .regular)

        // Label - For emphasized content
        static let labelLarge = Font.system(size: 17, weight: .medium)
        static let labelMedium = Font.system(size: 16, weight: .medium)
        static let labelSmall = Font.system(size: 15, weight: .medium)

        // Caption - For secondary/supporting text
        static let captionLarge = Font.system(size: 13, weight: .regular)
        static let captionMedium = Font.system(size: 12, weight: .regular)
        static let captionSmall = Font.system(size: 11, weight: .regular)

        // Button - For button labels
        static let buttonLarge = Font.system(size: 17, weight: .semibold)
        static let buttonMedium = Font.system(size: 16, weight: .semibold)
        static let buttonSmall = Font.system(size: 15, weight: .semibold)
    }

    // MARK: - Spacing
    enum Spacing {
        // Base spacing units
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
        static let xxxlarge: CGFloat = 32
        static let huge: CGFloat = 40
        static let massive: CGFloat = 48

        // Semantic spacing - use these for consistency
        static let screenEdge: CGFloat = 24        // Screen edge padding
        static let cardPadding: CGFloat = 20       // Inside cards
        static let sectionSpacing: CGFloat = 32    // Between major sections
        static let itemSpacing: CGFloat = 12       // Between list items
        static let tightSpacing: CGFloat = 8       // Tight spacing within groups
        static let componentSpacing: CGFloat = 16  // Between related components
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 24
        static let pill: CGFloat = .infinity
    }

    // MARK: - Shadows
    enum Shadow {
        static let light = ShadowStyle(
            color: Colors.shadowLight,
            radius: 6,
            x: 0,
            y: 3
        )

        static let medium = ShadowStyle(
            color: Colors.shadowMedium,
            radius: 12,
            x: 0,
            y: 4
        )

        static let heavy = ShadowStyle(
            color: Colors.shadowHeavy,
            radius: 16,
            x: 0,
            y: 6
        )
    }

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Dimensions
    enum Dimensions {
        // Buttons
        static let buttonHeightLarge: CGFloat = 56
        static let buttonHeightMedium: CGFloat = 52
        static let buttonHeightSmall: CGFloat = 44

        // Cards
        static let cardMinHeight: CGFloat = 80

        // Icons
        static let iconSmall: CGFloat = 16
        static let iconMedium: CGFloat = 20
        static let iconLarge: CGFloat = 24
        static let iconXLarge: CGFloat = 28

        // Touch Targets
        static let minTouchTarget: CGFloat = 44

        // Selection Indicators
        static let selectionIndicatorSize: CGFloat = 24
        static let selectionCheckmarkSize: CGFloat = 12
    }

    // MARK: - Animation
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
    }

    // MARK: - Border Widths
    enum BorderWidth {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 1.5
        static let thick: CGFloat = 2
    }
}

// MARK: - View Extensions for Easy Access
extension View {
    /// Apply a shadow style from the design system
    func applyShadow(_ style: DesignSystem.Shadow.ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }

    /// Apply light shadow (for unselected cards, inputs)
    func lightShadow() -> some View {
        self.applyShadow(DesignSystem.Shadow.light)
    }

    /// Apply medium shadow (for selected cards, elevated elements)
    func mediumShadow() -> some View {
        self.applyShadow(DesignSystem.Shadow.medium)
    }

    /// Apply heavy shadow (for modals, important elevated elements)
    func heavyShadow() -> some View {
        self.applyShadow(DesignSystem.Shadow.heavy)
    }

    /// Apply standard screen edge padding
    func screenEdgePadding() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.screenEdge)
    }

    /// Apply standard card padding
    func cardPadding() -> some View {
        self.padding(DesignSystem.Spacing.cardPadding)
    }
}

// MARK: - Design System Preview
#Preview("Design System Showcase") {
    ScrollView {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sectionSpacing) {

            // Typography Section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.itemSpacing) {
                Text("Typography")
                    .font(DesignSystem.Typography.titleLarge)

                Text("Display Medium")
                    .font(DesignSystem.Typography.displayMedium)

                Text("Title Medium")
                    .font(DesignSystem.Typography.titleMedium)

                Text("Body Large - This is the standard body text used throughout the app")
                    .font(DesignSystem.Typography.bodyLarge)

                Text("Caption Large - For secondary information")
                    .font(DesignSystem.Typography.captionLarge)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Divider()

            // Buttons Section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.itemSpacing) {
                Text("Buttons")
                    .font(DesignSystem.Typography.titleLarge)

                // Primary Button Example
                Capsule()
                    .fill(DesignSystem.Colors.primary)
                    .frame(height: DesignSystem.Dimensions.buttonHeightLarge)
                    .overlay(
                        Text("Primary Button")
                            .font(DesignSystem.Typography.buttonLarge)
                            .foregroundColor(DesignSystem.Colors.primaryText)
                    )

                // Secondary Button Example
                Capsule()
                    .strokeBorder(DesignSystem.Colors.borderMedium, lineWidth: DesignSystem.BorderWidth.medium)
                    .background(Capsule().fill(DesignSystem.Colors.cardBackground))
                    .frame(height: DesignSystem.Dimensions.buttonHeightLarge)
                    .lightShadow()
                    .overlay(
                        Text("Secondary Button")
                            .font(DesignSystem.Typography.buttonLarge)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    )
            }

            Divider()

            // Cards Section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.itemSpacing) {
                Text("Cards")
                    .font(DesignSystem.Typography.titleLarge)

                // Unselected Card
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Colors.cardBackground)
                    .lightShadow()
                    .frame(height: 100)
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unselected Card")
                                .font(DesignSystem.Typography.titleMedium)
                            Text("With light shadow")
                                .font(DesignSystem.Typography.captionLarge)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .cardPadding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    )

                // Selected Card
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Colors.cardBackground)
                    .mediumShadow()
                    .frame(height: 100)
                    .overlay(
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Card")
                                    .font(DesignSystem.Typography.titleMedium)
                                Text("With medium shadow and checkmark")
                                    .font(DesignSystem.Typography.captionLarge)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }

                            Spacer()

                            Circle()
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: DesignSystem.Dimensions.selectionIndicatorSize, height: DesignSystem.Dimensions.selectionIndicatorSize)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: DesignSystem.Dimensions.selectionCheckmarkSize, weight: .bold))
                                        .foregroundColor(DesignSystem.Colors.primaryText)
                                )
                        }
                        .cardPadding()
                    )
            }

            Divider()

            // Pills Section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.itemSpacing) {
                Text("Pills")
                    .font(DesignSystem.Typography.titleLarge)

                HStack(spacing: DesignSystem.Spacing.tightSpacing) {
                    // Unselected Pill
                    Capsule()
                        .strokeBorder(DesignSystem.Colors.borderLight, lineWidth: DesignSystem.BorderWidth.medium)
                        .background(Capsule().fill(DesignSystem.Colors.cardBackground))
                        .lightShadow()
                        .overlay(
                            Text("Unselected")
                                .font(DesignSystem.Typography.bodySmall)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, DesignSystem.Spacing.xlarge)
                                .padding(.vertical, DesignSystem.Spacing.medium)
                        )
                        .fixedSize()

                    // Selected Pill
                    Capsule()
                        .fill(DesignSystem.Colors.primary)
                        .lightShadow()
                        .overlay(
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                                Text("Selected")
                                    .font(DesignSystem.Typography.bodySmall)
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xlarge)
                            .padding(.vertical, DesignSystem.Spacing.medium)
                        )
                        .fixedSize()
                }
            }

            Divider()

            // Shadows Section
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.itemSpacing) {
                Text("Shadows")
                    .font(DesignSystem.Typography.titleLarge)

                HStack(spacing: DesignSystem.Spacing.large) {
                    VStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(DesignSystem.Colors.cardBackground)
                            .frame(width: 80, height: 80)
                            .lightShadow()
                        Text("Light")
                            .font(DesignSystem.Typography.captionLarge)
                    }

                    VStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(DesignSystem.Colors.cardBackground)
                            .frame(width: 80, height: 80)
                            .mediumShadow()
                        Text("Medium")
                            .font(DesignSystem.Typography.captionLarge)
                    }

                    VStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(DesignSystem.Colors.cardBackground)
                            .frame(width: 80, height: 80)
                            .heavyShadow()
                        Text("Heavy")
                            .font(DesignSystem.Typography.captionLarge)
                    }
                }
            }

            Divider()

            // Spacing Reference
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.itemSpacing) {
                Text("Spacing Reference")
                    .font(DesignSystem.Typography.titleLarge)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Screen Edge: \(Int(DesignSystem.Spacing.screenEdge))px")
                    Text("Section Spacing: \(Int(DesignSystem.Spacing.sectionSpacing))px")
                    Text("Card Padding: \(Int(DesignSystem.Spacing.cardPadding))px")
                    Text("Item Spacing: \(Int(DesignSystem.Spacing.itemSpacing))px")
                }
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .screenEdgePadding()
        .padding(.vertical, DesignSystem.Spacing.xxlarge)
    }
    .background(DesignSystem.Colors.background)
}
