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
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)

                    Text(subtitle)
                        .font(.smallCaption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Circle()
                    .stroke(isSelected ? Color.borderActive : .borderSubtle, lineWidth: LineWidth.thick)
                    .frame(width: Dimensions.radioOuter, height: Dimensions.radioOuter)
                    .overlay(
                        Circle()
                            .fill(Color.textPrimary)
                            .frame(width: Dimensions.radioInner, height: Dimensions.radioInner)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(isSelected ? Color.borderActive : .border, lineWidth: isSelected ? LineWidth.thick : LineWidth.thin)
            )
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
