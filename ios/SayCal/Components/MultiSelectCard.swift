import SwiftUI

struct MultiSelectCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack {
                Text(title)
                    .font(DSTypography.bodyMedium)
                    .foregroundColor(Color.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DSTypography.labelMedium)
                        .foregroundColor(Color.primaryBlue)
                }
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(isSelected ? Color.primaryBlue : Color.borderPrimary, lineWidth: isSelected ? DSBorder.thick : DSBorder.medium)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.quick, value: isSelected)
    }
}

struct MultiSelectPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSTypography.labelMedium)
                    .foregroundColor(Color.textPrimary)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DSTypography.labelMedium)
                        .foregroundColor(Color.primaryBlue)
                }
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.primaryBlue : Color.borderPrimary, lineWidth: isSelected ? DSBorder.thick : DSBorder.medium)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.quick, value: isSelected)
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
