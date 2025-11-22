import SwiftUI

struct MultiSelectPillGrid: View {
    let title: String
    @Binding var selectedItems: Set<String>
    let items: [String]

    @FocusState private var isTextFieldFocused: Bool
    @State private var displayItems: [String]
    @State private var isAddingItem: Bool = false
    @State private var newItem: String = ""

    init(title: String, selectedItems: Binding<Set<String>>, items: [String]) {
        self.title = title
        self._selectedItems = selectedItems
        self.items = items
        self._displayItems = State(initialValue: items)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            FormSectionHeader(title: title)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Spacing.xs) {

                if isAddingItem {
                    CustomInputField(
                        placeholder: "Enter custom item",
                        text: $newItem,
                        isFocused: $isTextFieldFocused
                    ) {
                        let trimmed = newItem.trimmingCharacters(in: .whitespaces)

                        guard !trimmed.isEmpty else {
                            withAnimation(.snappy(duration: 0.25)) {
                                isAddingItem = false
                                newItem = ""
                            }
                            return
                        }

                        guard !displayItems.contains(where: { $0.lowercased() == trimmed.lowercased() }) else {
                            withAnimation(.snappy(duration: 0.25)) {
                                isAddingItem = false
                                newItem = ""
                            }
                            return
                        }

                        withAnimation(.snappy(duration: 0.3)) {
                            displayItems.insert(trimmed, at: 0)
                            selectedItems.insert(trimmed)
                            isAddingItem = false
                            newItem = ""
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }

                ForEach(displayItems, id: \.self) { item in
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

                AddOptionButton {
                    withAnimation(.snappy(duration: 0.3)) {
                        isAddingItem = true
                        isTextFieldFocused = true
                    }
                }
            }
        }
        .onAppear {
            restoreCustomItems()
        }
        .onChange(of: selectedItems) { oldValue, newValue in
            restoreCustomItems()
        }
    }

    private func restoreCustomItems() {
        let predefinedItems = Set(items)
        let customItems = selectedItems.filter { !predefinedItems.contains($0) }

        for customItem in customItems {
            if !displayItems.contains(customItem) {
                displayItems.insert(customItem, at: 0)
            }
        }
    }
}
