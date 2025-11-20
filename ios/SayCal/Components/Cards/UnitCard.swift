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
            HStack(spacing: DS.Spacing.medium) {
                VStack(alignment: .leading, spacing: DS.Spacing.xxSmall) {
                    Text(title)
                        .font(DS.Typography.headline(weight: .semibold))
                        .foregroundColor(DS.Colors.label)

                    Text(subtitle)
                        .font(DS.Typography.subheadline())
                        .foregroundColor(DS.Colors.secondaryLabel)
                }

                Spacer()

                Circle()
                    .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: isSelected ? 2 : 1.5)
                    .frame(width: DS.Spacing.large, height: DS.Spacing.large)
                    .overlay(
                        Circle()
                            .fill(DS.Colors.label)
                            .frame(width: DS.Spacing.xSmall, height: DS.Spacing.xSmall)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(DS.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                    .fill(DS.Colors.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                            .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: DS.Spacing.small) {
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
    .padding(DS.Spacing.large)
    .background(DS.Colors.groupedBackground)
}
