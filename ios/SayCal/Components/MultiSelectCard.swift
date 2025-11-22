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
                    .font(.caption)
                    .foregroundColor(.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.iconSmall)
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xs)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xs)
                            .stroke(isSelected ? Color.borderActive : .border, lineWidth: isSelected ? LineWidth.regular : LineWidth.thin)
                    )
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
            action()
        } label: {
            HStack(spacing: Spacing.xxs) {
                Text(title)
                    .font(.smallCaption)
                    .foregroundColor(.textPrimary)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.icon)
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .fill(Color.cardBackground)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.borderActive : .border, lineWidth: isSelected ? LineWidth.regular : LineWidth.thin)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: Spacing.sm) {
        VStack(spacing: Spacing.xs) {
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
        ], spacing: Spacing.xs) {
            MultiSelectPill(title: "Peanuts", isSelected: true) {}
            MultiSelectPill(title: "Tree Nuts", isSelected: false) {}
            MultiSelectPill(title: "Milk", isSelected: false) {}
            MultiSelectPill(title: "Eggs", isSelected: true) {}
        }
    }
    .padding(Spacing.xxl)
    .appBackground()
}
