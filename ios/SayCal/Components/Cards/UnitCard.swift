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
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(UIColor.label))

                    Text(subtitle)
                        .font(.system(size: DesignTokens.FontSize.label))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                Spacer()

                Circle()
                    .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray4), lineWidth: isSelected ? DesignTokens.StrokeWidth.thick : DesignTokens.StrokeWidth.medium)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color(UIColor.label))
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? DesignTokens.StrokeWidth.thick : DesignTokens.StrokeWidth.thin)
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
