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
                    .font(Theme.Typography.callout)
                    .foregroundColor(Theme.Colors.label)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            .padding(.horizontal, Theme.Spacing.sm + 2)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(isSelected ? Theme.Colors.accentLight : Theme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.borderLight, lineWidth: isSelected ? Theme.BorderWidth.standard : Theme.BorderWidth.thin)
            )
            .cardShadow()
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
            HStack(spacing: Theme.Spacing.xxs + 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(isSelected ? .white : Theme.Colors.label)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
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
