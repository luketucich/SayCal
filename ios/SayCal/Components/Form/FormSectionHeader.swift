import SwiftUI

struct FormSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(DS.Typography.footnote(weight: .medium))
            .foregroundColor(DS.Colors.secondaryLabel)
    }
}
