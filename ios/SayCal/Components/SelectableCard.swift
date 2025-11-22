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
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(title)
                    .font(Theme.Typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.label)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm + 2)
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
                .font(Theme.Typography.callout)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : Theme.Colors.label)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.xs + 2)
                .background(
                    Capsule()
                        .fill(isSelected ? Theme.Colors.accent : Theme.Colors.background)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Theme.Colors.accent : Theme.Colors.borderLight, lineWidth: isSelected ? 0 : Theme.BorderWidth.thin)
                )
                .cardShadow()
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
                        .font(Theme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(selectedOption == option ? Theme.Colors.accent : Theme.Colors.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(
                            VStack(spacing: 0) {
                                Spacer()
                                if selectedOption == option {
                                    Rectangle()
                                        .fill(Theme.Colors.accent)
                                        .frame(height: 3)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 3)
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
