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
    }

    @ViewBuilder
    private var capsuleContent: some View {
        HStack(spacing: 4) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(UIColor.systemBackground))
            }

            Text(title)
                .font(.system(size: DesignTokens.FontSize.label, weight: .regular))
                .foregroundColor(isSelected ? Color(UIColor.systemBackground) : Color(UIColor.label))
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? DesignTokens.StrokeWidth.medium : DesignTokens.StrokeWidth.thin)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(.system(size: DesignTokens.FontSize.bodyLarge, weight: .medium))
            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : Color(UIColor.label))
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.ButtonHeight.pill)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: DesignTokens.StrokeWidth.thin)
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
