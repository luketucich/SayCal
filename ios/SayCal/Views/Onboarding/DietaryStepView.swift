import SwiftUI

struct DietaryStepView: View {
    @Binding var dietaryPreferences: Set<String>
    @Binding var allergies: Set<String>

    var isValid: Bool {
        // This step is optional, so always valid
        return true
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dietary Information")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("This helps us provide better recommendations. Both sections are optional.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // Dietary Preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dietary Preferences")
                        .font(.headline)

                    Text("Select all that apply")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(DietaryOptions.dietaryPreferences, id: \.self) { preference in
                            DietaryChip(
                                text: preference.replacingOccurrences(of: "_", with: " ").capitalized,
                                isSelected: dietaryPreferences.contains(preference),
                                action: {
                                    if dietaryPreferences.contains(preference) {
                                        dietaryPreferences.remove(preference)
                                    } else {
                                        dietaryPreferences.insert(preference)
                                    }
                                }
                            )
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Allergies
                VStack(alignment: .leading, spacing: 12) {
                    Text("Allergies & Intolerances")
                        .font(.headline)

                    Text("Select all that apply")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(DietaryOptions.commonAllergies, id: \.self) { allergy in
                            DietaryChip(
                                text: allergy.replacingOccurrences(of: "_", with: " ").capitalized,
                                isSelected: allergies.contains(allergy),
                                color: .red,
                                action: {
                                    if allergies.contains(allergy) {
                                        allergies.remove(allergy)
                                    } else {
                                        allergies.insert(allergy)
                                    }
                                }
                            )
                        }
                    }
                }

                // Skip button hint
                if dietaryPreferences.isEmpty && allergies.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("You can skip this step if none apply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct DietaryChip: View {
    let text: String
    let isSelected: Bool
    var color: Color = .accentColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                }
                Text(text)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Flow layout for wrapping chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowLayoutResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowLayoutResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }

    struct FlowLayoutResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

#Preview {
    NavigationStack {
        DietaryStepView(
            dietaryPreferences: .constant(["vegetarian", "gluten_free"]),
            allergies: .constant(["peanuts"])
        )
    }
}
