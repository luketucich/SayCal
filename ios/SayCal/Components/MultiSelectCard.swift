// Multi-select card components with checkmark indicators

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
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(UIColor.label))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// Compact multi-select pill for grid layouts
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
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(UIColor.label))

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.label))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        // Card style
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
        
        // Pill style in grid
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
