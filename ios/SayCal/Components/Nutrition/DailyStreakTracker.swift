import SwiftUI
import UIKit

struct DailyStreakTracker: View {
    let bigFont = UIFont.systemFont(ofSize: 48, weight: .semibold)
    let smallFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    
    var body: some View {
        HStack(alignment: .top) {
            Text("5")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
                .alignmentGuide(.top) { _ in
                    bigFont.ascender - bigFont.capHeight
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("DAY")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.label))
                    .tracking(1.5)
                Text("STREAK")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(UIColor.label))
                    .tracking(1.5)
            }
            .alignmentGuide(.top) { _ in
                smallFont.ascender - smallFont.capHeight
            }
            
            HStack(spacing: 8) {
                ForEach(0..<5) { _ in
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                }
            }
        }
    }
}

#Preview {
    DailyStreakTracker()
}
