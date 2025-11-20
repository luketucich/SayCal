import SwiftUI

struct TogglePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let style: PillStyle

    enum PillStyle {
        case capsule        // preferences and allergies
        case rounded        // gender selection
    }

    init(
        title: String,
        isSelected: Bool,
        style: PillStyle = .capsule,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Group {
                if style == .capsule {
                    capsuleContent
                } else {
                    roundedContent
                }
            }
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.quick, value: isSelected)
    }

    @ViewBuilder
    private var capsuleContent: some View {
        HStack(spacing: DSSpacing.xxs) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(DSTypography.labelSmall)
                    .foregroundColor(Color.buttonPrimaryText)
            }

            Text(title)
                .font(DSTypography.labelMedium)
                .foregroundColor(isSelected ? Color.buttonPrimaryText : Color.textPrimary)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(
            Capsule()
                .fill(isSelected ? Color.buttonPrimary : Color.cardBackground)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.buttonPrimary : Color.borderPrimary, lineWidth: isSelected ? DSBorder.medium : DSBorder.medium)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(DSTypography.headingMedium)
            .foregroundColor(isSelected ? Color.buttonPrimaryText : Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DSSize.buttonSmall)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.full)
                    .fill(isSelected ? Color.buttonPrimary : Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.full)
                            .stroke(isSelected ? Color.buttonPrimary : Color.borderPrimary, lineWidth: DSBorder.medium)
                    )
            )
    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 8) {
            TogglePill(title: "Vegan", isSelected: true) {}
            TogglePill(title: "Gluten-free", isSelected: false) {}
        }

        HStack(spacing: 12) {
            TogglePill(title: "Male", isSelected: true, style: .rounded) {}
            TogglePill(title: "Female", isSelected: false, style: .rounded) {}
        }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
