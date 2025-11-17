import SwiftUI

struct SelectableCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        SelectableCard(
            title: "Lose Weight",
            subtitle: "500 calorie deficit",
            isSelected: true
        ) {}

        SelectableCard(
            title: "Maintain Weight",
            subtitle: "No calorie adjustment",
            isSelected: false
        ) {}
    }
    .padding()
}
