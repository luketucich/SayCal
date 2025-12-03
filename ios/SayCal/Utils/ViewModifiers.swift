import SwiftUI

// MARK: - Shimmer Effect

/// A reusable shimmer loading effect
struct ShimmerView: View {
    let width: CGFloat
    let height: CGFloat
    let duration: Double

    init(width: CGFloat, height: CGFloat, duration: Double = 1.5) {
        self.width = width
        self.height = height
        self.duration = duration
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration

            ZStack {
                RoundedRectangle(cornerRadius: height / 3)
                    .fill(Color(.systemGray5))
                    .frame(width: width, height: height)

                RoundedRectangle(cornerRadius: height / 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(.systemGray4).opacity(0.5),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width, height: height)
                    .offset(x: phase * width * 2 - width)
            }
            .clipShape(RoundedRectangle(cornerRadius: height / 3))
        }
    }
}

// MARK: - Reveal Modifier

/// A modifier that creates a staggered reveal animation effect
struct RevealModifier: ViewModifier {
    let delay: Double
    let revealed: Bool

    func body(content: Content) -> some View {
        content
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(delay), value: revealed)
    }
}

extension View {
    /// Applies a reveal animation with the specified delay and revealed state
    func reveal(delay: Double, revealed: Bool) -> some View {
        modifier(RevealModifier(delay: delay, revealed: revealed))
    }
}
