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
            HStack(spacing: DS.Spacing.medium) {
                Text(title)
                    .font(DS.Typography.subheadline(weight: .regular))
                    .foregroundColor(DS.Colors.label)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DS.Typography.caption(weight: .semibold))
                        .foregroundColor(DS.Colors.label)
                }
            }
            .padding(.horizontal, DS.Spacing.small)
            .padding(.vertical, DS.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                    .fill(DS.Colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                            .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: isSelected ? 1.5 : 1)
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
            HStack(spacing: DS.Spacing.xxSmall) {
                Text(title)
                    .font(DS.Typography.footnote(weight: .regular))
                    .foregroundColor(DS.Colors.label)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DS.Typography.footnote())
                        .foregroundColor(DS.Colors.label)
                }
            }
            .padding(.horizontal, DS.Spacing.small)
            .padding(.vertical, DS.Spacing.xSmall)
            .background(
                Capsule()
                    .fill(DS.Colors.background)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: DS.Spacing.small) {
        VStack(spacing: DS.Spacing.xSmall) {
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

        Divider().padding(.vertical, DS.Spacing.small)

        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DS.Spacing.xSmall) {
            MultiSelectPill(title: "Peanuts", isSelected: true) {}
            MultiSelectPill(title: "Tree Nuts", isSelected: false) {}
            MultiSelectPill(title: "Milk", isSelected: false) {}
            MultiSelectPill(title: "Eggs", isSelected: true) {}
        }
    }
    .padding(DS.Spacing.large)
    .background(DS.Colors.groupedBackground)
}
