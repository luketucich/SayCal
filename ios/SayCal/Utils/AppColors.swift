import SwiftUI

extension Color {
    // MARK: - App Color Scheme

    /// Primary background - main view background
    /// Light mode: Very light cool gray
    /// Dark mode: Very dark neutral black
    static var appBackground: Color {
        Color(
            light: Color(red: 0.97, green: 0.97, blue: 0.98), // #F8F8FA
            dark: Color(red: 0.039, green: 0.039, blue: 0.042) // #0A0A0B
        )
    }

    /// Secondary background - cards, buttons, elevated components
    /// Light mode: Pure white
    /// Dark mode: Lighter cool gray
    static var appCardBackground: Color {
        Color(
            light: Color(red: 1.0, green: 1.0, blue: 1.0), // #FFFFFF
            dark: Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1F
        )
    }

    /// Shadow color for elevated components
    static var appShadow: Color {
        Color(
            light: Color.black.opacity(0.08),
            dark: Color.black.opacity(0.4)
        )
    }

    /// Shadow color for floating elements
    static var floatingShadowColor: Color {
        Color(
            light: Color.black.opacity(0.35),
            dark: Color.black.opacity(0.7)
        )
    }

    /// Subtle stroke color for elevated components
    /// Light mode: Light gray
    /// Dark mode: Subtle lighter gray
    static var appStroke: Color {
        Color(
            light: Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.12), // Subtle black
            dark: Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.12) // Subtle white
        )
    }

    // MARK: - Macro Colors

    /// Orange for carbohydrates (energy, warmth)
    static var carbsColor: Color {
        .orange
    }

    /// Purple for fats (richness, premium)
    static var fatColor: Color {
        .purple
    }

    /// Blue for protein (strength, muscle)
    static var proteinColor: Color {
        .blue
    }

    /// Helper initializer for light/dark mode colors
    private init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Shadow Modifiers

extension View {
    /// Applies standard card shadow for elevated components
    func cardShadow() -> some View {
        self.shadow(color: Color.appShadow, radius: 8, x: 0, y: 2)
    }

    /// Applies stronger shadow for floating elements like tab bar
    func floatingShadow() -> some View {
        self.shadow(
            color: Color.floatingShadowColor,
            radius: 20,
            x: 0,
            y: 8
        )
    }
}
