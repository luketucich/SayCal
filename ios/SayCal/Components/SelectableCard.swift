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
            VStack(alignment: .leading, spacing: DS.Spacing.xxSmall) {
                Text(title)
                    .font(DS.Typography.callout(weight: .medium))
                    .foregroundColor(DS.Colors.label)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DS.Typography.footnote())
                        .foregroundColor(DS.Colors.secondaryLabel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DS.Spacing.medium)
            .padding(.vertical, DS.Spacing.small)
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
                .font(DS.Typography.subheadline(weight: isSelected ? .semibold : .regular))
                .foregroundColor(DS.Colors.label)
                .padding(.horizontal, DS.Spacing.large)
                .padding(.vertical, DS.Spacing.xSmall)
                .background(
                    Capsule()
                        .fill(DS.Colors.background)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? DS.Colors.label : DS.Colors.separator, lineWidth: isSelected ? 2 : 1)
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
                        .font(DS.Typography.callout(weight: .medium))
                        .foregroundColor(DS.Colors.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.xSmall)
                        .background(
                            VStack(spacing: 0) {
                                Spacer()
                                if selectedOption == option {
                                    Rectangle()
                                        .fill(DS.Colors.label)
                                        .frame(height: 2)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 2)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DS.Spacing.large)
    }
}

#Preview {
    VStack(spacing: DS.Spacing.medium) {
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

        HStack(spacing: DS.Spacing.xSmall) {
            SelectablePill(title: "Weekend", isSelected: false) {}
            SelectablePill(title: "Week", isSelected: true) {}
            SelectablePill(title: "Month", isSelected: false) {}
        }

        TabSelector(
            options: ["Metric", "Imperial"],
            selectedOption: .constant("Metric")
        )
    }
    .padding(DS.Spacing.large)
    .background(DS.Colors.groupedBackground)
}
