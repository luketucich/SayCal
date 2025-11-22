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
            HapticManager.shared.light()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: DesignTokens.FontSize.bodyLarge, weight: .medium))
                    .foregroundColor(Color(UIColor.label))

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: DesignTokens.FontSize.small))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? DesignTokens.StrokeWidth.thick : DesignTokens.StrokeWidth.thin)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct SelectablePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Text(title)
                .font(.system(size: DesignTokens.FontSize.body, weight: isSelected ? .semibold : .regular))
                .foregroundColor(Color(UIColor.label))
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(UIColor.systemBackground))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? DesignTokens.StrokeWidth.thick : DesignTokens.StrokeWidth.thin)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct TabSelector: View {
    let options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    HapticManager.shared.selection()
                    selectedOption = option
                } label: {
                    Text(option)
                        .font(.system(size: DesignTokens.FontSize.bodyLarge, weight: .medium))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(
                            VStack(spacing: 0) {
                                Spacer()
                                if selectedOption == option {
                                    Rectangle()
                                        .fill(Color(UIColor.label))
                                        .frame(height: DesignTokens.StrokeWidth.thick)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: DesignTokens.StrokeWidth.thick)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
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
        
        HStack(spacing: 8) {
            SelectablePill(title: "Weekend", isSelected: false) {}
            SelectablePill(title: "Week", isSelected: true) {}
            SelectablePill(title: "Month", isSelected: false) {}
        }
        
        TabSelector(
            options: ["Metric", "Imperial"],
            selectedOption: .constant("Metric")
        )
    }
    .padding()
    .background(Color(UIColor.systemGray6))
}
