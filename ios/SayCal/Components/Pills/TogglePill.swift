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
        HStack(spacing: DS.Spacing.xxSmall) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(DS.Typography.caption2(weight: .semibold))
                    .foregroundColor(DS.Colors.background)
            }

            Text(title)
                .font(DS.Typography.footnote(weight: .regular))
                .foregroundColor(isSelected ? DS.Colors.background : DS.Colors.label)
        }
        .padding(.horizontal, DS.Spacing.small)
        .padding(.vertical, DS.Spacing.xSmall)
        .background(
            Capsule()
                .fill(isSelected ? DS.Colors.label : DS.Colors.background)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: isSelected ? 1.5 : 1)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(DS.Typography.callout(weight: .medium))
            .foregroundColor(isSelected ? DS.Colors.background : DS.Colors.label)
            .frame(maxWidth: .infinity)
            .frame(height: DS.Layout.buttonHeightSmall)
            .background(
                RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                    .fill(isSelected ? DS.Colors.label : DS.Colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                            .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    VStack(spacing: DS.Spacing.xLarge) {
        HStack(spacing: DS.Spacing.xSmall) {
            TogglePill(title: "Vegan", isSelected: true) {}
            TogglePill(title: "Gluten-free", isSelected: false) {}
        }

        HStack(spacing: DS.Spacing.small) {
            TogglePill(title: "Male", isSelected: true, style: .rounded) {}
            TogglePill(title: "Female", isSelected: false, style: .rounded) {}
        }
    }
    .padding(DS.Spacing.large)
    .background(DS.Colors.background)
}
