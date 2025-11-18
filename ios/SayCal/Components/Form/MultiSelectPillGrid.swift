import SwiftUI

struct MultiSelectPillGrid: View {
    let title: String
    @Binding var selectedItems: Set<String>
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FormSectionHeader(title: title)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(items, id: \.self) { item in
                    TogglePill(
                        title: item.replacingOccurrences(of: "_", with: " ").capitalized,
                        isSelected: selectedItems.contains(item)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedItems.contains(item) {
                                selectedItems.remove(item)
                            } else {
                                selectedItems.insert(item)
                            }
                        }
                    }
                }
            }
        }
    }
}
