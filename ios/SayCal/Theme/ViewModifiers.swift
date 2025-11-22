import SwiftUI

// MARK: - Custom View Modifiers
// Reusable styling patterns for consistent UI

// MARK: - Background Modifiers

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.appBackground)
    }
}

struct CardStyleModifier: ViewModifier {
    var darkMode: Bool = false

    func body(content: Content) -> some View {
        content
            .background(darkMode ? Color.cardBackgroundDark : Color.cardBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(
                color: Shadows.medium.color,
                radius: Shadows.medium.radius,
                x: Shadows.medium.x,
                y: Shadows.medium.y
            )
    }
}

struct LargeShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Shadows.large.color,
                radius: Shadows.large.radius,
                x: Shadows.large.x,
                y: Shadows.large.y
            )
    }
}

struct SmallShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Shadows.small.color,
                radius: Shadows.small.radius,
                x: Shadows.small.x,
                y: Shadows.small.y
            )
    }
}

// MARK: - Button Style Modifiers

struct PrimaryButtonStyleModifier: ViewModifier {
    var filled: Bool = true
    var height: CGFloat = Dimensions.buttonHeightLarge

    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(filled ? Color.textPrimary : Color.clear)
            .foregroundColor(filled ? Color(uiColor: .systemBackground) : Color.textPrimary)
            .cornerRadius(CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.pill)
                    .stroke(Color.textPrimary, lineWidth: filled ? 0 : LineWidth.regular)
            )
    }
}

struct PillButtonStyleModifier: ViewModifier {
    var filled: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.lg)
            .background(filled ? Color.textPrimary : Color.clear)
            .foregroundColor(filled ? Color(uiColor: .systemBackground) : Color.textPrimary)
            .cornerRadius(CornerRadius.pill)
    }
}

// MARK: - Input Field Modifiers

struct InputFieldStyleModifier: ViewModifier {
    var height: CGFloat = Dimensions.inputHeight

    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .padding(.horizontal, Spacing.lg)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.xs)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .stroke(Color.border.opacity(Opacity.visible), lineWidth: LineWidth.thin)
            )
    }
}

// MARK: - Card Modifiers

struct SelectableCardModifier: ViewModifier {
    var isSelected: Bool
    var cornerRadius: CGFloat = CornerRadius.lg

    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected ? Color.borderActive : Color.border,
                        lineWidth: isSelected ? LineWidth.thick : LineWidth.regular
                    )
            )
    }
}

struct MultiSelectCardModifier: ViewModifier {
    var isSelected: Bool
    var cornerRadius: CGFloat = CornerRadius.xs

    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color.border,
                        lineWidth: isSelected ? LineWidth.regular : LineWidth.thin
                    )
            )
    }
}

struct PillStyleModifier: ViewModifier {
    var isSelected: Bool

    func body(content: Content) -> some View {
        content
            .frame(height: Dimensions.buttonHeightMedium)
            .padding(.horizontal, Spacing.lg)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.pill)
                    .stroke(
                        isSelected ? Color.borderActive : Color.border,
                        lineWidth: isSelected ? LineWidth.regular : LineWidth.thin
                    )
            )
    }
}

// MARK: - Picker Modifiers

struct PickerButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.lg)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.border, lineWidth: LineWidth.thin)
            )
    }
}

// MARK: - Section Modifiers

struct SectionContainerModifier: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.sm

    func body(content: Content) -> some View {
        content
            .padding(Spacing.lg)
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - View Extensions

extension View {
    // MARK: Backgrounds
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }

    func cardStyle(darkMode: Bool = false) -> some View {
        modifier(CardStyleModifier(darkMode: darkMode))
    }

    func largeShadow() -> some View {
        modifier(LargeShadowModifier())
    }

    func smallShadow() -> some View {
        modifier(SmallShadowModifier())
    }

    // MARK: Buttons
    func primaryButton(filled: Bool = true, height: CGFloat = Dimensions.buttonHeightLarge) -> some View {
        modifier(PrimaryButtonStyleModifier(filled: filled, height: height))
    }

    func pillButton(filled: Bool = true) -> some View {
        modifier(PillButtonStyleModifier(filled: filled))
    }

    // MARK: Input Fields
    func inputFieldStyle(height: CGFloat = Dimensions.inputHeight) -> some View {
        modifier(InputFieldStyleModifier(height: height))
    }

    // MARK: Cards
    func selectableCard(isSelected: Bool, cornerRadius: CGFloat = CornerRadius.lg) -> some View {
        modifier(SelectableCardModifier(isSelected: isSelected, cornerRadius: cornerRadius))
    }

    func multiSelectCard(isSelected: Bool, cornerRadius: CGFloat = CornerRadius.xs) -> some View {
        modifier(MultiSelectCardModifier(isSelected: isSelected, cornerRadius: cornerRadius))
    }

    func pillStyle(isSelected: Bool) -> some View {
        modifier(PillStyleModifier(isSelected: isSelected))
    }

    // MARK: Pickers
    func pickerButton() -> some View {
        modifier(PickerButtonStyleModifier())
    }

    // MARK: Sections
    func sectionContainer(cornerRadius: CGFloat = CornerRadius.sm) -> some View {
        modifier(SectionContainerModifier(cornerRadius: cornerRadius))
    }

    // MARK: Conditional Modifiers
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
