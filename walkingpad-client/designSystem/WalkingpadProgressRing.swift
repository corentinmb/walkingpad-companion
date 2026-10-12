import SwiftUI

/// Use a fraction in 0...1 and provide a spoken description of the represented goal.
struct WalkingpadProgressRing<Content: View>: View {
    let progress: Double
    let accessibilityDescription: String
    @ViewBuilder var content: () -> Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var fraction: Double { progress.isFinite ? min(max(progress, 0), 1) : 0 }

    var body: some View {
        ZStack {
            Circle().stroke(WalkingpadTheme.Colors.track, lineWidth: WalkingpadTheme.Layout.ringStroke)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(WalkingpadTheme.Colors.accentGradient,
                        style: StrokeStyle(lineWidth: WalkingpadTheme.Layout.ringStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : WalkingpadTheme.progressAnimation, value: fraction)
            content()
        }
        .padding(WalkingpadTheme.Layout.ringStroke / 2)
        .frame(width: WalkingpadTheme.Layout.ringSize, height: WalkingpadTheme.Layout.ringSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }
}
