import SwiftUI

/// Unified pill component for toggleable options (dietary preferences, allergies, gender, etc.)
struct TogglePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let style: PillStyle

    enum PillStyle {
        case capsule        // For dietary preferences and allergies
        case rounded        // For gender selection
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
        HStack(spacing: 4) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(UIColor.systemBackground))
            }

            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(isSelected ? Color(UIColor.systemBackground) : Color(UIColor.label))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 1.5 : 1)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : Color(UIColor.label))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: 1)
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
