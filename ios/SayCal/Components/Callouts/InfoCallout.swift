import SwiftUI

struct InfoCallout: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.tertiaryLabel))

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
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
