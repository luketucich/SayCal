import SwiftUI

struct MacroCard: View {
    let title: String
    let percentage: Int
    let color: Color
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(UIColor.secondaryLabel))

            Text("\(percentage)%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}
