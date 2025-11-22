import SwiftUI

struct SelectableCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

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
            HStack(spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(DesignSystem.Typography.callout(weight: .semibold))
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.footnote(weight: .regular))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(isSelected ? DesignSystem.Colors.primary.opacity(0.08) : DesignSystem.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(
                                isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.borderSubtle,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Animations.quick, value: isSelected)
            .animation(DesignSystem.Animations.quick, value: isPressed)
            .shadow(
                color: isSelected ? DesignSystem.Colors.primary.opacity(0.15) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct SelectablePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Text(title)
                .font(DesignSystem.Typography.subheadline(weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.sm + 2)
                .background(
                    Capsule()
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: DesignSystem.Colors.primaryGradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [DesignSystem.Colors.surface, DesignSystem.Colors.surface],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    isSelected ? Color.clear : DesignSystem.Colors.borderSubtle,
                                    lineWidth: 1.5
                                )
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(DesignSystem.Animations.quick, value: isSelected)
                .animation(DesignSystem.Animations.quick, value: isPressed)
                .shadow(
                    color: isSelected ? DesignSystem.Colors.primary.opacity(0.25) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct TabSelector: View {
    let options: [String]
    @Binding var selectedOption: String
    @Namespace private var animation

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(options, id: \.self) { option in
                Button {
                    HapticManager.shared.selection()
                    withAnimation(DesignSystem.Animations.smooth) {
                        selectedOption = option
                    }
                } label: {
                    Text(option)
                        .font(DesignSystem.Typography.callout(weight: selectedOption == option ? .semibold : .medium))
                        .foregroundColor(selectedOption == option ? .white : DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(
                            ZStack {
                                if selectedOption == option {
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                        .fill(
                                            LinearGradient(
                                                colors: DesignSystem.Colors.primaryGradient,
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .matchedGeometryEffect(id: "tab", in: animation)
                                        .shadow(
                                            color: DesignSystem.Colors.primary.opacity(0.3),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md + 2)
                .fill(DesignSystem.Colors.surfaceSecondary)
        )
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
