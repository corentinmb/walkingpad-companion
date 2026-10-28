import SwiftUI
import AppKit

final class WorkoutStatisticsWindow {
    static let shared = WorkoutStatisticsWindow()
    private var window: NSWindow?

    func show(workout: Workout) {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 640),
                                  styleMask: [.titled, .closable, .miniaturizable, .resizable],
                                  backing: .buffered, defer: false)
            window.title = "Walkingpad Companion — Statistics"
            window.contentView = NSHostingView(rootView: WorkoutStatisticsView(workout: workout))
            window.minSize = NSSize(width: 620, height: 440)
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

struct WorkoutStatisticsView: View {
    @ObservedObject var workout: Workout

    var body: some View {
        let history = workout.loadAll().sorted { $0.date > $1.date }
        let total = history.reduce(0) { $0 + $1.calibratedSteps }
        let best = history.map(\.calibratedSteps).max() ?? 0

        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your walking statistics").font(.title2.weight(.semibold))
                    Text("Saved on your Mac · Updated live from Companion")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "figure.walk")
                    .font(.title).foregroundStyle(WalkingpadTheme.Colors.accent)
            }

            HStack(spacing: 12) {
                metric("Today", steps: workout.calibratedSteps)
                metric("Total", steps: total)
                metric("Best day", steps: best)
            }

            HStack(spacing: 24) {
                Label(WorkoutSummary.clock(workout.walkingSeconds), systemImage: "clock")
                Label(String(format: "%.2f km", Double(workout.distance) / 1000), systemImage: "map")
                Spacer()
                Text("Today").foregroundStyle(.secondary)
            }
            .font(.subheadline).monospacedDigit()

            Divider()
            HStack {
                Text("Walking history").font(.headline)
                Spacer()
                Text("Estimated steps").font(.subheadline).foregroundStyle(.secondary)
            }

            if history.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis").font(.largeTitle)
                    Text("Your walks will appear here.")
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(history.enumerated()), id: \.offset) { _, entry in
                            historyRow(entry, maximum: best)
                            Divider()
                        }
                    }
                }
            }

            Text("Personal calibration applies to new steps at 2–3 km/h. Older walks without calibration keep their recorded counts.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WalkingpadTheme.Colors.panel)
    }

    private func metric(_ title: String, steps: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text(WorkoutSummary.integer(steps))
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .monospacedDigit().lineLimit(1).minimumScaleFactor(0.5)
            Text("estimated steps").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(WalkingpadTheme.Colors.control))
    }

    private func historyRow(_ entry: WorkoutSaveData, maximum: Int) -> some View {
        HStack(spacing: 16) {
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .frame(width: 125, alignment: .leading)
            ProgressView(value: Double(max(entry.calibratedSteps, 0)), total: Double(max(maximum, 1)))
                .tint(WalkingpadTheme.Colors.accent)
                .accessibilityLabel("Daily steps")
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(WorkoutSummary.integer(entry.calibratedSteps)) steps").fontWeight(.medium)
                Text("\(String(format: "%.2f km", Double(entry.distance) / 1000)) · \(WorkoutSummary.clock(entry.walkingSeconds))")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .monospacedDigit().frame(width: 160, alignment: .trailing)
        }
        .padding(.vertical, 12)
    }
}
