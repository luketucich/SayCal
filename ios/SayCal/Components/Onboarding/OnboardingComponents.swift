import SwiftUI

// MARK: - Header
/// Standardized header for onboarding screens with title and subtitle
struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(Color(UIColor.label))

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.top, 24)
    }
}

// MARK: - Bottom Bar
/// Standardized bottom navigation bar for onboarding screens
struct OnboardingBottomBar: View {
    let showBackButton: Bool
    let nextButtonText: String
    let nextButtonIcon: String
    let isNextEnabled: Bool
    let onBack: () -> Void
    let onNext: () -> Void

    init(
        showBackButton: Bool = true,
        nextButtonText: String = "Next",
        nextButtonIcon: String = "arrow.right",
        isNextEnabled: Bool = true,
        onBack: @escaping () -> Void = {},
        onNext: @escaping () -> Void
    ) {
        self.showBackButton = showBackButton
        self.nextButtonText = nextButtonText
        self.nextButtonIcon = nextButtonIcon
        self.isNextEnabled = isNextEnabled
        self.onBack = onBack
        self.onNext = onNext
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color(UIColor.systemGray5))

            HStack {
                if showBackButton {
                    Button {
                        onBack()
                    } label: {
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(UIColor.label))
                            .underline()
                    }
                }

                Spacer()

                Button {
                    onNext()
                } label: {
                    HStack(spacing: 4) {
                        Text(nextButtonText)
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: nextButtonIcon)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isNextEnabled ? Color(UIColor.label) : Color(UIColor.systemGray4))
                    )
                }
                .disabled(!isNextEnabled)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Toggle Pill
/// Unified pill component for toggleable options (dietary preferences, allergies, gender, etc.)
struct TogglePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let style: PillStyle

    enum PillStyle {
        case capsule        // For dietary preferences and allergies
        case rounded        // For gender selection
    }

    init(
        title: String,
        isSelected: Bool,
        style: PillStyle = .capsule,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.style = style
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                if style == .capsule {
                    capsuleContent
                } else {
                    roundedContent
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var capsuleContent: some View {
        HStack(spacing: 4) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(isSelected ? .white : Color(UIColor.label))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 1.5 : 1)
                )
        )
    }

    @ViewBuilder
    private var roundedContent: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isSelected ? .white : Color(UIColor.label))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Color(UIColor.label) : Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Info Callout
/// Informational callout box with icon
struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.tertiaryLabel))

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Add Button
/// Button for adding custom options (allergies, preferences, etc.)
struct AddOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                Text("Add")
                    .font(.system(size: 14))
            }
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    .background(
                        Capsule()
                            .fill(Color(UIColor.systemGray6))
                    )
            )
        }
    }
}

// MARK: - Custom Input Field
/// Styled text field for custom input in onboarding screens
struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 14))
            .foregroundColor(Color(UIColor.label))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        Capsule()
                            .stroke(Color(UIColor.label), lineWidth: 1.5)
                    )
            )
            .focused($isFocused)
            .onSubmit(onSubmit)
    }
}

// MARK: - Unit Card
/// Card for selecting units (metric/imperial)
struct UnitCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
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
    VStack(spacing: 24) {
        OnboardingHeader(
            title: "Sample Title",
            subtitle: "This is a sample subtitle for the onboarding screen"
        )

        HStack(spacing: 8) {
            TogglePill(title: "Vegan", isSelected: true) {}
            TogglePill(title: "Gluten-free", isSelected: false) {}
        }

        HStack(spacing: 12) {
            TogglePill(title: "Male", isSelected: true, style: .rounded) {}
            TogglePill(title: "Female", isSelected: false, style: .rounded) {}
        }

        InfoCallout(message: "You can skip this step and update preferences later")

        AddOptionButton {}

        UnitCard(
            title: "Metric",
            subtitle: "Kilograms • Centimeters",
            isSelected: true
        ) {}
    }
    .padding()
    .background(Color(UIColor.systemBackground))
}
