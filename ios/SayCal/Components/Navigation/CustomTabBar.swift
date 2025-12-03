import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 12) {
            // Daily Tab
            TabBarButton(
                icon: selectedTab == .daily ? "house.fill" : "house",
                isSelected: selectedTab == .daily
            ) {
                HapticManager.shared.light()
                selectedTab = .daily
            }

            // Recipes Tab
            TabBarButton(
                icon: selectedTab == .recipes ? "book.closed.fill" : "book.closed",
                isSelected: selectedTab == .recipes
            ) {
                HapticManager.shared.light()
                selectedTab = .recipes
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(width: 63, height: 50)
                .background(
                    isSelected ? Color.primary.opacity(0.1) : Color.clear,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.daily))
}
