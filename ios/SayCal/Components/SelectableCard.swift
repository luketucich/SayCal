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
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.medium) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(DesignSystem.Typography.titleMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.captionLarge)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Selection Indicator
                Circle()
                    .strokeBorder(
                        isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.borderMedium,
                        lineWidth: DesignSystem.BorderWidth.thick
                    )
                    .background(
                        Circle().fill(isSelected ? DesignSystem.Colors.primary : Color.clear)
                    )
                    .frame(
                        width: DesignSystem.Dimensions.selectionIndicatorSize,
                        height: DesignSystem.Dimensions.selectionIndicatorSize
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: DesignSystem.Dimensions.selectionCheckmarkSize, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.primaryText)
                            }
                        }
                    )
            }
            .cardPadding()
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Colors.cardBackground)
                    .applyShadow(isSelected ? DesignSystem.Shadow.medium : DesignSystem.Shadow.light)
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
            withAnimation(DesignSystem.Animation.spring) {
                action()
            }
        } label: {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                }

                Text(title)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primaryText : DesignSystem.Colors.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.xlarge)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(
                Capsule()
                    .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.cardBackground)
                    .lightShadow()
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                isSelected ? Color.clear : DesignSystem.Colors.borderLight,
                                lineWidth: DesignSystem.BorderWidth.medium
                            )
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
                    withAnimation(DesignSystem.Animation.spring) {
                        selectedOption = option
                    }
                } label: {
                    Text(option)
                        .font(DesignSystem.Typography.labelLarge)
                        .foregroundColor(selectedOption == option ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.medium)
                        .background(
                            VStack(spacing: 0) {
                                Spacer()
                                if selectedOption == option {
                                    Capsule()
                                        .fill(DesignSystem.Colors.primary)
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
        .padding(.horizontal, DesignSystem.Spacing.screenEdge)
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
