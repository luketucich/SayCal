// Form section header component with secondary label styling

import SwiftUI

struct FormSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color(UIColor.secondaryLabel))
    }
}
