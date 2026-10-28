import SwiftUI

/// Pure UI: services are supplied by ContentView, allowing deterministic previews.
struct MenuBarPanel<Footer: View>: View {
    let summary: WorkoutSummary
    let connected: Bool
    let device: DeviceState?
    @Binding var dailyStepGoal: Int
    let startOrStop: () -> Void
    let changeSpeed: (Int) -> Void
    let changeMode: (WalkingMode) -> Void
    @ViewBuilder var footer: () -> Footer

    @State private var metric: WorkoutMetric = .steps
    @State private var showingGoal = false

    private var goal: Int { WorkoutSummary.normalizedGoal(dailyStepGoal) }
    private var running: Bool { connected && (device?.speed ?? 0) > 0 }
    private var hasStatus: Bool { connected && device != nil }
    private var progress: Double { summary.progress(toward: goal) }
    private var status: String {
        if !connected { return "Waiting for treadmill" }
        if device == nil { return "Reading treadmill status" }
        return running ? "Walking" : "Stopped"
    }

    var body: some View {
        VStack(spacing: WalkingpadTheme.Spacing.medium) {
            WalkingpadSegmentedControl(options: WorkoutMetric.allCases, selection: $metric, label: { $0.title })
                .accessibilityLabel("Daily metric")

            WalkingpadProgressRing(progress: progress,
                accessibilityDescription: "\(metric.caption): \(summary.value(for: metric)). Daily step goal: \(Int(progress * 100)) percent of \(WorkoutSummary.integer(goal)) steps.") {
                VStack(spacing: WalkingpadTheme.Spacing.small) {
                    Text(summary.value(for: metric))
                        .font(metric == .duration ? WalkingpadTheme.Typography.duration : WalkingpadTheme.Typography.metric)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(metric.caption)
                        .font(WalkingpadTheme.Typography.caption)
                        .tracking(1.5)
                        .foregroundStyle(WalkingpadTheme.Colors.secondaryText)
                }
                .padding(.horizontal, WalkingpadTheme.Spacing.large)
            }
            .padding(.top, WalkingpadTheme.Spacing.small)

            if let rawSteps = summary.rawSteps {
                VStack(spacing: WalkingpadTheme.Spacing.tiny) {
                    Text("Estimated · \(WorkoutSummary.integer(summary.steps)) steps")
                    Text("P1 raw · \(WorkoutSummary.integer(rawSteps)) steps")
                }
                .font(WalkingpadTheme.Typography.detail)
                .monospacedDigit()
                .foregroundStyle(WalkingpadTheme.Colors.secondaryText)
                .help("Personal calibration: ×0.545 at 2 km/h, ×0.818 at 2.5 km/h, ×1.20 at 3 km/h; interpolated between. Other speeds and earlier uncalibrated steps use the raw count. The ring uses estimated steps.")
            }

            Button { showingGoal.toggle() } label: {
                Label("\(Int(progress * 100))% of \(WorkoutSummary.integer(goal)) steps", systemImage: "target")
            }
            .buttonStyle(WalkingpadQuietButtonStyle())
            .help("Change your daily step goal")
            .popover(isPresented: $showingGoal, arrowEdge: .bottom) {
                goalEditor
            }

            HStack(spacing: WalkingpadTheme.Spacing.medium) {
                ForEach(WorkoutMetric.allCases.filter { $0 != metric }) { item in
                    Text(summary.secondaryValue(for: item))
                        .font(WalkingpadTheme.Typography.body)
                        .monospacedDigit()
                        .foregroundStyle(WalkingpadTheme.Colors.secondaryText)
                        .accessibilityLabel("\(item.title): \(summary.secondaryValue(for: item))")
                    if item == WorkoutMetric.allCases.filter({ $0 != metric }).first {
                        Rectangle().fill(WalkingpadTheme.Colors.divider).frame(width: 1, height: 13)
                            .accessibilityHidden(true)
                    }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            VStack(spacing: WalkingpadTheme.Spacing.tiny) {
                Label(status, systemImage: connected ? "circle.fill" : "antenna.radiowaves.left.and.right")
                    .font(WalkingpadTheme.Typography.detail)
                    .foregroundStyle(connected ? WalkingpadTheme.Colors.accent : WalkingpadTheme.Colors.secondaryText)
                Text(hasStatus ? "Session · \(WorkoutSummary.clock(device?.walkingTimeSeconds ?? 0))" : "Today's totals stay available")
                    .font(WalkingpadTheme.Typography.detail)
                    .foregroundStyle(WalkingpadTheme.Colors.secondaryText)
            }

            HStack(spacing: WalkingpadTheme.Spacing.extraLarge) {
                speedButton(delta: -5, symbol: "minus", title: "Decrease speed by 0.5 km/h")
                Button(action: startOrStop) {
                    Image(systemName: running ? "stop.fill" : "play.fill")
                }
                .buttonStyle(WalkingpadCircularButtonStyle(primary: true))
                .disabled(!hasStatus)
                .accessibilityLabel(running ? "Stop walking" : "Start walking")
                .help(running ? "Stop the treadmill (0 km/h)" : "Start the treadmill")
                speedButton(delta: 5, symbol: "plus", title: "Increase speed by 0.5 km/h")
            }
            .padding(.top, WalkingpadTheme.Spacing.small)

            Text(hasStatus ? "Speed · \(String(format: "%.1f", Double(device?.speed ?? 0) / 10)) km/h" : "Speed · —")
                .font(WalkingpadTheme.Typography.body)
                .monospacedDigit()
                .foregroundStyle(WalkingpadTheme.Colors.secondaryText)

            WalkingpadSegmentedControl(options: [WalkingMode.manual, .automatic],
                selection: Binding(get: { device?.walkingMode ?? .manual }, set: changeMode),
                label: { $0 == .manual ? "Manual" : "Automatic" })
                .disabled(!hasStatus)
                .opacity(hasStatus ? 1 : 0.5)
                .accessibilityLabel("Treadmill mode")
                .help("Speed controls are available while walking in manual mode")

            Rectangle().fill(WalkingpadTheme.Colors.divider).frame(height: 1).accessibilityHidden(true)
            footer()
        }
        .padding(WalkingpadTheme.Spacing.large)
        .frame(width: WalkingpadTheme.Layout.panelWidth)
        .background(WalkingpadPanelBackground())
        .foregroundStyle(WalkingpadTheme.Colors.text)
    }

    private func speedButton(delta: Int, symbol: String, title: String) -> some View {
        Button { changeSpeed(delta) } label: { Image(systemName: symbol) }
            .buttonStyle(WalkingpadCircularButtonStyle())
            .disabled(SpeedControlPolicy.targetSpeed(from: device, connected: connected, delta: delta) == nil)
            .accessibilityLabel(title)
            .help(title)
    }

    private var goalEditor: some View {
        VStack(alignment: .leading, spacing: WalkingpadTheme.Spacing.medium) {
            Text("Daily step goal").font(WalkingpadTheme.Typography.body)
            Stepper(value: Binding(get: { goal }, set: { dailyStepGoal = $0 }),
                    in: WorkoutSummary.goalRange, step: 1_000) {
                Text("\(WorkoutSummary.integer(goal)) steps").monospacedDigit()
            }
            Text("Saved on this Mac. The ring tracks daily steps on every tab.")
                .font(WalkingpadTheme.Typography.detail)
                .foregroundStyle(WalkingpadTheme.Colors.secondaryText)
            Button("Done") { showingGoal = false }
        }
        .padding(WalkingpadTheme.Spacing.large)
        .frame(width: 280)
    }
}
