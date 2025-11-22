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
        HStack(spacing: Theme.Spacing.xxs) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(isSelected ? .white : Theme.Colors.label)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs + 2)
        .background(
            Capsule()
                .fill(isSelected ? Theme.Colors.accent : Theme.Colors.background)
        )
        .overlay(
            Capsule()
                .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.borderLight, lineWidth: isSelected ? 0 : Theme.BorderWidth.thin)
        )
        .cardShadow()
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(Theme.Typography.body)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : Theme.Colors.label)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Theme.Colors.accent : Theme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.borderLight, lineWidth: isSelected ? 0 : Theme.BorderWidth.thin)
            )
            .cardShadow()
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
