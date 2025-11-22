import SwiftUI

struct FormSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(DesignSystem.Typography.captionLarge)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .textCase(.none)
    }
}
