import SwiftUI

struct MultiSelectCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Text(title)
                    .font(DesignSystem.Typography.bodyLarge)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                Circle()
                    .strokeBorder(
                        isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.borderMedium,
                        lineWidth: DesignSystem.BorderWidth.thick
                    )
                    .background(
                        Circle().fill(isSelected ? DesignSystem.Colors.primary : Color.clear)
                    )
                    .frame(
                        width: DesignSystem.Dimensions.selectionIndicatorSize,
                        height: DesignSystem.Dimensions.selectionIndicatorSize
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: DesignSystem.Dimensions.selectionCheckmarkSize, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                            }
                        }
                    )
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.componentSpacing)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Colors.cardBackground)
                    .applyShadow(isSelected ? DesignSystem.Shadow.medium : DesignSystem.Shadow.light)
            )
        }
        .buttonStyle(.plain)
    }
}

struct MultiSelectPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Text(title)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryText : DesignSystem.Colors.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(
                Capsule()
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.cardBackground)
                    .lightShadow()
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                isSelected ? Color.clear : DesignSystem.Colors.borderLight,
                                lineWidth: DesignSystem.BorderWidth.medium
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        VStack(spacing: 8) {
            MultiSelectCard(
                title: "Vegetarian",
                isSelected: true
            ) {}

            MultiSelectCard(
                title: "Vegan",
                isSelected: false
            ) {}
            
            MultiSelectCard(
                title: "Gluten Free",
                isSelected: false
            ) {}
        }

        Divider().padding(.vertical)

        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 10) {
            MultiSelectPill(title: "Peanuts", isSelected: true) {}
            MultiSelectPill(title: "Tree Nuts", isSelected: false) {}
            MultiSelectPill(title: "Milk", isSelected: false) {}
            MultiSelectPill(title: "Eggs", isSelected: true) {}
        }
    }
    .padding()
    .background(Color(UIColor.systemGray6))
}
