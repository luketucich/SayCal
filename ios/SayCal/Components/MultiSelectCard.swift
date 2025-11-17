import SwiftUI

struct MultiSelectCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        MultiSelectCard(
            title: "Vegetarian",
            isSelected: true
        ) {}

        MultiSelectCard(
            title: "Vegan",
            isSelected: false
        ) {}
    }
    .padding()
}
