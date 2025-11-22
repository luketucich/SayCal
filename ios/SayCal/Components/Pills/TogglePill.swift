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
        HStack(spacing: Spacing.xs) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.iconSmall)
                    .foregroundColor(Color(uiColor: .systemBackground))
            }

            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? Color(uiColor: .systemBackground) : .textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule()
                .fill(isSelected ? Color.textPrimary : .cardBackground)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.textPrimary : .border, lineWidth: LineWidth.regular)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(.bodyMedium)
            .foregroundColor(isSelected ? Color(uiColor: .systemBackground) : .textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: Dimensions.buttonHeightMedium)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.pill)
                    .fill(isSelected ? Color.textPrimary : .cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.pill)
                            .stroke(isSelected ? Color.textPrimary : .border, lineWidth: LineWidth.regular)
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
