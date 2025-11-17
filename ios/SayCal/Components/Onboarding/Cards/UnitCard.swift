import SwiftUI

// Radio button card for metric vs imperial selection
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
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                Spacer()

                Circle()
                    .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray4), lineWidth: isSelected ? 2 : 1.5)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color(UIColor.label))
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 2 : 1)
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
