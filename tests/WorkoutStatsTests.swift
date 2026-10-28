import Foundation

// In-memory persistence keeps this regression test away from user workout data.
class FileSystem {
    static var data: Data?
    func load(filename: String) -> Data? { Self.data }
    func save(filename: String, data: Data) { Self.data = data }
}

@main
struct WorkoutStatsTests {
    static func main() throws {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        FileSystem.data = try JSONEncoder().encode(WorkoutsSaveData(workouts: [
            WorkoutSaveData(steps: 100, distance: 30, walkingSeconds: 60, date: yesterday),
            WorkoutSaveData(steps: 7671, distance: 2320, walkingSeconds: 4000, date: today)
        ]))
        let workout = Workout()
        precondition(workout.steps == 7671, "Saved totals must still load at startup")
        precondition(workout.calibratedSteps == 7671, "Legacy totals without speed history must stay unchanged")
        workout.steps = 10085
        workout.distance = 3050
        workout.walkingSeconds = 5563
        let stats = workout.loadAll()
        precondition(stats.count == 2, "Today's workout must not be duplicated")
        precondition(stats.first?.steps == 100, "Historical totals must be preserved")
        precondition(stats.last?.steps == 10085, "Stats must use the live step total")
        precondition(stats.last?.distance == 3050, "Stats must use the live distance")
        precondition(stats.last?.walkingSeconds == 5563, "Stats must use the live duration")
        let saved = try JSONDecoder().decode(WorkoutsSaveData.self, from: FileSystem.data!)
        precondition(saved.workouts.last?.steps == 7671, "Reading stats must not write to disk")
        FileSystem.data = nil
        precondition(workout.loadAll().last?.steps == 10085, "Unsaved first workouts must appear in stats")
        workout.steps = 0
        workout.distance = 0
        workout.walkingSeconds = 0
        precondition(workout.loadAll().isEmpty, "An empty workout must not create a walking day")

        // Faster polling repeats the same cumulative Bluetooth counter. Repeated
        // packets must not turn five reported steps into more than five steps.
        for repeats in [1, 10] {
            let liveWorkout = Workout()
            var previous: DeviceState?
            for steps in 100...105 {
                let state = DeviceState(time: today, walkingTimeSeconds: steps,
                                        speed: 20, steps: steps, distance: steps * 10,
                                        deviceName: "P1", statusType: .currentStatus)
                for _ in 0..<repeats {
                    liveWorkout.update(previous, state)
                    previous = state
                }
            }
            precondition(liveWorkout.steps == 105, "Repeated Bluetooth counters must not duplicate steps")
            precondition(liveWorkout.distance == 1050, "Repeated Bluetooth counters must not duplicate distance")
            precondition(liveWorkout.walkingSeconds == 105, "Repeated Bluetooth counters must not duplicate time")
        }
        FileSystem.data = nil
        let calibrated = Workout()
        var previous = DeviceState(time: today, speed: 20, deviceName: "P1", statusType: .currentStatus)
        calibrated.update(nil, previous)
        func advance(steps: Int, speed: Int) {
            let next = DeviceState(time: today, walkingTimeSeconds: steps, speed: speed,
                                   steps: steps, distance: steps * 10, deviceName: "P1", statusType: .currentStatus)
            calibrated.update(previous, next)
            previous = next
        }
        for steps in 1...165 { advance(steps: steps, speed: 20) }
        precondition(calibrated.steps == 165 && calibrated.calibratedSteps == 90,
                     "2 km/h must retain 165 raw steps and estimate 90, including fractional increments")
        advance(steps: 165, speed: 20)
        precondition(calibrated.calibratedSteps == 90, "Duplicate packets must not change calibrated totals")
        advance(steps: 165, speed: 30)
        for steps in 166...265 { advance(steps: steps, speed: 30) }
        precondition(calibrated.calibratedSteps == 210, "100 new steps at 3 km/h must add 120 without recalibrating earlier steps")
        precondition(calibrated.steps == 265 && calibrated.distance == 2650,
                     "Calibration must preserve raw steps and distance")
        precondition(abs(StepCalibration.factor(speed: 25) - 90.0 / 110.0) < 0.000001,
                     "2.5 km/h must use the measured 90/110 factor")
        precondition(abs(StepCalibration.factor(speed: 22) - (90.0 / 165.0 + (90.0 / 110.0 - 90.0 / 165.0) * 0.4)) < 0.000001,
                     "Speeds below 2.5 km/h must interpolate using the middle measurement")
        precondition(abs(StepCalibration.factor(speed: 28) - (90.0 / 110.0 + (1.2 - 90.0 / 110.0) * 0.6)) < 0.000001,
                     "Speeds above 2.5 km/h must interpolate using the middle measurement")
        advance(steps: 265, speed: 10)
        advance(steps: 275, speed: 10)
        precondition(calibrated.calibratedSteps == 220, "Unmeasured speeds must retain raw increments")
        calibrated.save()
        let restored = Workout()
        precondition(restored.steps == 275 && restored.calibratedSteps == 220,
                     "Both raw and calibrated totals must survive saving and loading")
        precondition(restored.loadAll().last?.calibratedStepTotal == restored.calibratedStepTotal,
                     "Live stats must preserve calibration precision")
        precondition(restored.loadAll().last?.calibratedSteps == 220,
                     "History exported to Stats must use estimated steps rather than the 275 raw steps")
        let legacyEntry = WorkoutSaveData(steps: 100, distance: 30, walkingSeconds: 60, date: yesterday)
        precondition(legacyEntry.calibratedSteps == 100,
                     "History without speed information must retain its recorded total")
        restored.lastUpdateTime = yesterday
        restored.resetIfDateChanged()
        precondition(restored.steps == 0 && restored.calibratedSteps == 0,
                     "A new day must reset both step totals")
        FileSystem.data = nil
        let middleSpeed = Workout()
        var middleState = DeviceState(time: today, speed: 25, deviceName: "P1", statusType: .currentStatus)
        middleSpeed.update(nil, middleState)
        for step in 1...110 {
            var next = middleState
            next.steps = step
            middleSpeed.update(middleState, next)
            middleState = next
        }
        precondition(middleSpeed.steps == 110 && middleSpeed.calibratedSteps == 90,
                     "110 individual raw steps at 2.5 km/h must accumulate to 90 estimated steps")
        let initial = Workout()
        initial.update(nil, previous)
        precondition(initial.calibratedSteps == initial.steps,
                     "An initial session counter with unknown speed history must not be retroactively calibrated")
        print("Workout stats regression checks passed")
    }
}
