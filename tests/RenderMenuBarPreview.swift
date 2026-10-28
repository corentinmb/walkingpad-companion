import SwiftUI
import AppKit

@main
struct RenderWalkingpadMenu {
    static func main() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.prohibited)
        let directory = CommandLine.arguments[1]
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        for dark in [false, true] {
            for stateName in ["stopped", "running", "automatic", "disconnected"] {
                let connected = stateName != "disconnected"
                let running = stateName == "running" || stateName == "automatic"
                let state = connected ? DeviceState(time: Date(), walkingTimeSeconds: running ? 1243 : 0,
                    speed: running ? 25 : 0, steps: 10085, distance: 3050,
                    walkingMode: stateName == "automatic" ? .automatic : .manual,
                    deviceName: "Walkingpad", statusType: .currentStatus) : nil
                let view = MenuBarPanel(summary: WorkoutSummary(steps: 5501, distance: 3050, walkingSeconds: 5563, rawSteps: 10085),
                    connected: connected, device: state, dailyStepGoal: .constant(12000),
                    startOrStop: {}, changeSpeed: { _ in }, changeMode: { _ in }) {
                        HStack {
                            Label("Stats", systemImage: "chart.bar.xaxis")
                            Spacer()
                            Label("Login", systemImage: "person.crop.circle")
                            Spacer()
                            Label("Quit", systemImage: "power")
                        }
                        .font(WalkingpadTheme.Typography.detail)
                        .foregroundStyle(WalkingpadTheme.Colors.secondaryText)
                    }
                let host = NSHostingView(rootView: view)
                let appearance = NSAppearance(named: dark ? .darkAqua : .aqua)!
                app.appearance = appearance
                host.appearance = appearance
                let size = host.fittingSize
                let window = NSWindow(contentRect: NSRect(origin: .zero, size: size), styleMask: .borderless,
                    backing: .buffered, defer: false)
                window.appearance = appearance
                window.contentView = host
                host.setFrameSize(size)
                host.layoutSubtreeIfNeeded()
                RunLoop.current.run(until: Date().addingTimeInterval(0.1))
                guard let bitmap = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { fatalError("No bitmap") }
                host.cacheDisplay(in: host.bounds, to: bitmap)
                guard let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("No PNG") }
                let name = "menubar-\(dark ? "dark" : "light")-\(stateName).png"
                try png.write(to: URL(fileURLWithPath: directory).appendingPathComponent(name))
                print("\(name): \(size.width) × \(size.height)")
            }
        }
    }
}
