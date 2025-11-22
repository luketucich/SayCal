import SwiftUI

struct FormSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.smallCaptionMedium)
            .foregroundColor(.textSecondary)
    }
}
