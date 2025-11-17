import SwiftUI

/// Informational callout box with icon
struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.tertiaryLabel))

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding()
        .background(Color(UIColor.systemBackground))
}
