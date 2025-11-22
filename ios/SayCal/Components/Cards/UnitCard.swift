import SwiftUI

struct UnitCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)

                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }

                Spacer()

                Circle()
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.border, lineWidth: isSelected ? Theme.BorderWidth.thick : Theme.BorderWidth.standard)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(isSelected ? Theme.Colors.accentLight : Theme.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.borderLight, lineWidth: isSelected ? Theme.BorderWidth.thick : Theme.BorderWidth.thin)
            )
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        UnitCard(
            title: "Metric",
            subtitle: "Kilograms • Centimeters",
            isSelected: true
        ) {}

        UnitCard(
            title: "Imperial",
            subtitle: "Pounds • Feet & Inches",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
