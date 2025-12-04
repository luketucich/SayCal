import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 12) {
            // Daily Tab
            TabBarButton(
                icon: selectedTab == .daily ? "house.fill" : "house",
                label: "Daily",
                isSelected: selectedTab == .daily,
                namespace: animation
            ) {
                HapticManager.shared.light()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .daily
                }
            }

            // Micros Tab
            TabBarButton(
                icon: selectedTab == .micros ? "chart.bar.doc.horizontal.fill" : "chart.bar.doc.horizontal",
                label: "Micros",
                isSelected: selectedTab == .micros,
                namespace: animation
            ) {
                HapticManager.shared.light()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .micros
                }
            }

            // Profile Tab
            TabBarButton(
                icon: selectedTab == .profile ? "person.fill" : "person",
                label: "Profile",
                isSelected: selectedTab == .profile,
                namespace: animation
            ) {
                HapticManager.shared.light()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .profile
                }
            }
        }
        .padding(6)
        .background(Color.appCardBackground, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.appStroke, lineWidth: 0.5)
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .primary : .secondary)

                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(width: 63, height: 50)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                            .matchedGeometryEffect(id: "tab_background", in: namespace)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.daily))
}
