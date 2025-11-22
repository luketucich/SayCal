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
        HStack(spacing: 6) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.systemBackground))
            }

            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(isSelected ? Color(UIColor.systemBackground) : AppColors.primaryText)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule()
                .fill(isSelected ? AppColors.primaryText : Color(UIColor.systemBackground))
                .overlay(
                    Capsule()
                        .stroke(isSelected ? AppColors.primaryText : Color(UIColor.systemGray5), lineWidth: 1.5)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(AppTypography.bodyMedium)
            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : AppColors.primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.pill)
                    .fill(isSelected ? AppColors.primaryText : Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.pill)
                            .stroke(isSelected ? AppColors.primaryText : Color(UIColor.systemGray5), lineWidth: 1.5)
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
