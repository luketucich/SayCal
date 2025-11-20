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
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .font(DSTypography.headingMedium)
                    .foregroundColor(Color.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DSTypography.captionLarge)
                        .foregroundColor(Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
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
                .font(isSelected ? DSTypography.labelLarge : DSTypography.bodyMedium)
                .foregroundColor(Color.textPrimary)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.xs)
                .background(
                    Capsule()
                        .fill(Color.cardBackground)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.primaryBlue : Color.borderPrimary, lineWidth: isSelected ? DSBorder.thick : DSBorder.medium)
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(DSAnimation.quick, value: isSelected)
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
                    withAnimation(DSAnimation.quick) {
                        selectedOption = option
                    }
                } label: {
                    Text(option)
                        .font(DSTypography.headingMedium)
                        .foregroundColor(selectedOption == option ? Color.textPrimary : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.xs)
                        .background(
                            VStack(spacing: 0) {
                                Spacer()
                                if selectedOption == option {
                                    Rectangle()
                                        .fill(Color.primaryBlue)
                                        .frame(height: DSBorder.extraThick)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: DSBorder.extraThick)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.md)
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
