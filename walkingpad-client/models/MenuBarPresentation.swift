import Foundation

enum WorkoutMetric: String, CaseIterable, Identifiable {
    case steps, duration, distance

    var id: Self { self }
    var title: String {
        switch self {
        case .steps: return "Steps"
        case .duration: return "Time"
        case .distance: return "Distance"
        }
    }
    var caption: String {
        switch self {
        case .steps: return "STEPS TODAY"
        case .duration: return "WALKING TIME TODAY"
        case .distance: return "KILOMETERS TODAY"
        }
    }
}

/// Display-only daily totals. Device counters and persistence stay in the services.
struct WorkoutSummary {
    let steps: Int
    let distance: Int
    let walkingSeconds: Int

    static let defaultGoal = 12_000
    static let goalRange = 1_000...50_000

    static func normalizedGoal(_ goal: Int) -> Int {
        min(max(goal, goalRange.lowerBound), goalRange.upperBound)
    }

    func progress(toward goal: Int) -> Double {
        min(Double(max(steps, 0)) / Double(Self.normalizedGoal(goal)), 1)
    }

    func value(for metric: WorkoutMetric, locale: Locale = .current) -> String {
        switch metric {
        case .steps:
            return Self.integer(max(steps, 0), locale: locale)
        case .duration:
            return Self.clock(walkingSeconds)
        case .distance:
            let formatter = NumberFormatter()
            formatter.locale = locale
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: Double(max(distance, 0)) / 1000)) ?? "0"
        }
    }

    func secondaryValue(for metric: WorkoutMetric) -> String {
        let value = value(for: metric)
        switch metric {
        case .steps: return "\(value) steps"
        case .duration: return value
        case .distance: return "\(value) km"
        }
    }

    static func integer(_ value: Int, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    static func clock(_ seconds: Int) -> String {
        let seconds = max(seconds, 0)
        return String(format: "%d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }
}

enum SpeedControlPolicy {
    // Preserve the range previously offered by the app's speed grid (km/h × 10).
    static let range = 10...85

    static func targetSpeed(from state: DeviceState?, connected: Bool, delta: Int) -> UInt8? {
        guard connected, let state = state, state.walkingMode == .manual,
              range.contains(state.speed), delta == 5 || delta == -5 else { return nil }
        let target = state.speed + delta
        guard range.contains(target) else { return nil }
        return UInt8(target)
    }
}
