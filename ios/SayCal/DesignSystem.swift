import SwiftUI

// MARK: - Design System
// Extracted from Fuse wallet design - all colors use Apple semantic colors for automatic dark/light mode support

enum DS {

    // MARK: - Colors
    enum Colors {
        // Backgrounds
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        static let groupedBackground = Color(uiColor: .systemGroupedBackground)

        // Text
        static let label = Color(uiColor: .label)
        static let secondaryLabel = Color(uiColor: .secondaryLabel)
        static let tertiaryLabel = Color(uiColor: .tertiaryLabel)
        static let quaternaryLabel = Color(uiColor: .quaternaryLabel)

        // Fills (for cards, elevated content)
        static let fill = Color(uiColor: .systemFill)
        static let secondaryFill = Color(uiColor: .secondarySystemFill)
        static let tertiaryFill = Color(uiColor: .tertiarySystemFill)

        // Separator
        static let separator = Color(uiColor: .separator)
        static let opaqueSeparator = Color(uiColor: .opaqueSeparator)

        // Accent (purple/violet brand color - adaptive)
        static let accent = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.61, green: 0.47, blue: 1.0, alpha: 1.0) // Lighter purple for dark mode
                : UIColor(red: 0.48, green: 0.27, blue: 0.93, alpha: 1.0) // Darker purple for light mode
        })

        // Success (green)
        static let success = Color(uiColor: .systemGreen)

        // Warning
        static let warning = Color(uiColor: .systemOrange)

        // Error
        static let error = Color(uiColor: .systemRed)
    }

    // MARK: - Typography
    enum Typography {
        // Large display numbers (like $0.00)
        static func largeTitle(weight: Font.Weight = .bold) -> Font {
            .system(.largeTitle, design: .default, weight: weight)
        }

        // Screen titles (like "Earn", "Wallet")
        static func title(weight: Font.Weight = .bold) -> Font {
            .system(.title, design: .default, weight: weight)
        }

        static func title2(weight: Font.Weight = .bold) -> Font {
            .system(.title2, design: .default, weight: weight)
        }

        static func title3(weight: Font.Weight = .semibold) -> Font {
            .system(.title3, design: .default, weight: weight)
        }

        // Card titles, important labels
        static func headline(weight: Font.Weight = .semibold) -> Font {
            .system(.headline, design: .default, weight: weight)
        }

        // Body text, descriptions
        static func body(weight: Font.Weight = .regular) -> Font {
            .system(.body, design: .default, weight: weight)
        }

        static func callout(weight: Font.Weight = .regular) -> Font {
            .system(.callout, design: .default, weight: weight)
        }

        static func subheadline(weight: Font.Weight = .regular) -> Font {
            .system(.subheadline, design: .default, weight: weight)
        }

        // Small labels, captions
        static func footnote(weight: Font.Weight = .regular) -> Font {
            .system(.footnote, design: .default, weight: weight)
        }

        static func caption(weight: Font.Weight = .regular) -> Font {
            .system(.caption, design: .default, weight: weight)
        }

        static func caption2(weight: Font.Weight = .regular) -> Font {
            .system(.caption2, design: .default, weight: weight)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
        static let xxxLarge: CGFloat = 40
        static let huge: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
        static let xxxLarge: CGFloat = 28
    }

    // MARK: - Shadows
    enum Shadow {
        static func small() -> some View {
            return EmptyView().shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }

        static func medium() -> some View {
            return EmptyView().shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }

        static func large() -> some View {
            return EmptyView().shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 4)
        }
    }

    // MARK: - Layout
    enum Layout {
        // Screen padding
        static let screenPadding: CGFloat = 20
        static let screenPaddingHorizontal: CGFloat = 20
        static let screenPaddingVertical: CGFloat = 16

        // Card padding
        static let cardPadding: CGFloat = 16
        static let cardPaddingLarge: CGFloat = 20

        // Button heights
        static let buttonHeightSmall: CGFloat = 40
        static let buttonHeightMedium: CGFloat = 48
        static let buttonHeightLarge: CGFloat = 56

        // Icon sizes
        static let iconSmall: CGFloat = 20
        static let iconMedium: CGFloat = 24
        static let iconLarge: CGFloat = 32
        static let iconXLarge: CGFloat = 40
        static let iconXXLarge: CGFloat = 48
    }

    // MARK: - Materials (for glass/blur effects)
    enum Materials {
        static let ultraThin = Material.ultraThin
        static let thin = Material.thin
        static let regular = Material.regular
        static let thick = Material.thick
        static let ultraThick = Material.ultraThick
    }
}

// MARK: - View Extensions for Easy Application

extension View {
    // Shadow modifiers
    func shadowSmall() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    func shadowMedium() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    func shadowLarge() -> some View {
        self.shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 4)
    }

    // Card styling
    func cardStyle(padding: CGFloat = DS.Layout.cardPadding, cornerRadius: CGFloat = DS.CornerRadius.large) -> some View {
        self
            .padding(padding)
            .background(DS.Colors.secondaryBackground)
            .cornerRadius(cornerRadius)
            .shadowSmall()
    }

    // Elevated card (more prominent)
    func elevatedCardStyle(padding: CGFloat = DS.Layout.cardPaddingLarge, cornerRadius: CGFloat = DS.CornerRadius.xLarge) -> some View {
        self
            .padding(padding)
            .background(DS.Colors.secondaryBackground)
            .cornerRadius(cornerRadius)
            .shadowMedium()
    }
}

// MARK: - Custom Shape for Cards with specific corners rounded
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
