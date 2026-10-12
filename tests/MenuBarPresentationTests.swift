import Foundation

@main
struct MenuBarPresentationTests {
    static func main() {
        let sample = WorkoutSummary(steps: 10085, distance: 3050, walkingSeconds: 5563)
        precondition(sample.value(for: .duration, locale: Locale(identifier: "en_US")) == "1:32:43")
        precondition(sample.value(for: .steps, locale: Locale(identifier: "en_US")) == "10,085")
        precondition(sample.value(for: .distance, locale: Locale(identifier: "fr_FR")) == "3,05")
        precondition(abs(sample.progress(toward: 12000) - 0.8404166667) < 0.00001)
        precondition(sample.progress(toward: 1000) == 1)
        precondition(WorkoutSummary.normalizedGoal(0) == 1000)
        precondition(WorkoutSummary.normalizedGoal(-100) == 1000)
        precondition(WorkoutSummary.normalizedGoal(Int.max) == 50000)
        let empty = WorkoutSummary(steps: -1, distance: -1, walkingSeconds: -1)
        precondition(empty.progress(toward: 0) == 0)
        precondition(empty.value(for: .duration) == "0:00:00")
        precondition(empty.value(for: .distance, locale: Locale(identifier: "en_US")) == "0.00")
        let long = WorkoutSummary(steps: 0, distance: 0, walkingSeconds: 360000)
        precondition(long.value(for: .duration) == "100:00:00")
        var state = DeviceState(time: Date(), speed: 25, deviceName: "Test", statusType: .currentStatus)
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: 5) == 30)
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: -5) == 20)
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: false, delta: 5) == nil)
        precondition(SpeedControlPolicy.targetSpeed(from: nil, connected: true, delta: 5) == nil)
        state.speed = 0
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: 5) == nil)
        state.speed = 10
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: -5) == nil)
        state.speed = 85
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: 5) == nil)
        state.walkingMode = .automatic
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: -5) == nil)
        state.walkingMode = .manual
        state.speed = Int.max
        precondition(SpeedControlPolicy.targetSpeed(from: state, connected: true, delta: 5) == nil)
        print("Menu bar presentation regression checks passed")
    }
}
