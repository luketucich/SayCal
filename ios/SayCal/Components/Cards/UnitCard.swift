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
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(title)
                        .font(DSTypography.headingMedium)
                        .foregroundColor(Color.textPrimary)

                    Text(subtitle)
                        .font(DSTypography.bodySmall)
                        .foregroundColor(Color.textSecondary)
                }

                Spacer()

                Circle()
                    .stroke(isSelected ? Color.primaryBlue : Color.borderPrimary, lineWidth: isSelected ? DSBorder.thick : DSBorder.medium)
                    .frame(width: DSSpacing.lg, height: DSSpacing.lg)
                    .overlay(
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: DSSpacing.xs, height: DSSpacing.xs)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(isSelected ? Color.primaryBlue : Color.borderPrimary, lineWidth: isSelected ? DSBorder.thick : DSBorder.medium)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.quick, value: isSelected)
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
