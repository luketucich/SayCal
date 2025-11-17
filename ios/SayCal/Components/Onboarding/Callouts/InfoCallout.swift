import SwiftUI

// Simple info message with an icon
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
    }
}

#Preview {
    InfoCallout(message: "You can skip this step and update preferences later")
        .padding()
        .background(Color(UIColor.systemBackground))
}
