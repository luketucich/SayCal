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
                    .font(.system(size: DesignTokens.FontSize.body, weight: .regular))
                    .foregroundColor(Color(UIColor.label))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: DesignTokens.FontSize.small, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? DesignTokens.StrokeWidth.medium : DesignTokens.StrokeWidth.thin)
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
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: DesignTokens.FontSize.label, weight: .regular))
                    .foregroundColor(Color(UIColor.label))

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: DesignTokens.FontSize.label))
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                Capsule()
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? DesignTokens.StrokeWidth.medium : DesignTokens.StrokeWidth.thin)
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
