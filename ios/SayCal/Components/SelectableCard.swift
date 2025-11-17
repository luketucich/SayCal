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
            HapticManager.light()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(UIColor.label))

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// Compact pill-style selectable card (like the date/duration selector)
struct SelectablePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.light()
            action()
        } label: {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(Color(UIColor.label))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(UIColor.systemBackground))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color(UIColor.label) : Color(UIColor.systemGray5), lineWidth: isSelected ? 2 : 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// Tab selector style (like Stays/Experiences)
struct TabSelector: View {
    let options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    HapticManager.selection()
                    selectedOption = option
                } label: {
                    Text(option)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            VStack(spacing: 0) {
                                Spacer()
                                if selectedOption == option {
                                    Rectangle()
                                        .fill(Color(UIColor.label))
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
