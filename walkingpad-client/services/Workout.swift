import SwiftUI
import Foundation

public typealias OnChangeCallback = (_ change: Change) -> Void

enum StepCalibration {
    // Personal P1 measurements: 90 real / 165 reported at 2 km/h,
    // approximately 90 / 110 at 2.5 km/h, and 120 / 100 at 3 km/h.
    static func factor(speed: Int) -> Double {
        guard (20...30).contains(speed) else { return 1 }
        let middle = 90.0 / 110.0
        if speed <= 25 {
            let lower = 90.0 / 165.0
            return lower + (middle - lower) * Double(speed - 20) / 5
        }
        return middle + (1.2 - middle) * Double(speed - 25) / 5
    }
}

struct WorkoutState {
    var steps: Int
    var distance: Int
    var walkingSeconds: Int
}

class Workout: ObservableObject {
    @Published
    public var steps: Int = 0

    @Published
    var calibratedStepTotal: Double? = nil

    var calibratedSteps: Int {
        Int((calibratedStepTotal ?? Double(steps)).rounded())
    }
    
    @Published
    public var distance: Int = 0
    
    @Published
    public var walkingSeconds: Int = 0
    
    public var lastUpdateTime: Date = Date()
    
    public var onChangeCallback: OnChangeCallback =  {_ in }
    
    init() {
        self.load()
    }
    
    public func resetIfDateChanged() {
        let now = Date()
        if now.get(.day) != self.lastUpdateTime.get(.day) && self.steps > 0 {
            self.distance = 0
            self.steps = 0
            self.calibratedStepTotal = 0
            self.walkingSeconds = 0
        }
    }
    
    public func update(_ oldState: DeviceState?, _ newState: DeviceState) {
        self.resetIfDateChanged()

        let stepDiff = newState.steps - (oldState?.steps ?? 0)
        let distanceDiff = newState.distance - (oldState?.distance ?? 0)
        let walkingTimeDiff = newState.walkingTimeSeconds - ( oldState?.walkingTimeSeconds ?? 0)
        
        if ((self.steps > 0 && oldState == nil) || stepDiff < 0 || distanceDiff < 0) {
            return
        }
        if (oldState != nil && oldState?.speed != newState.speed) {
            save()
        }
        
        print("adding steps=\(stepDiff) distance=\(distanceDiff)")
        
        if (self.steps > 0 && newState.statusType == .currentStatus) {
            let change = Change(
                oldTime: self.lastUpdateTime,
                newTime: newState.time,
                stepsDiff: stepDiff,
                oldSpeed: oldState?.speed ?? 0,
                newSpeed: newState.speed
            )
            self.onChangeCallback(change)
        }
        
        // Keep fractional steps across packets. Only calibrate intervals whose
        // previous speed is known; a first packet can contain a whole session.
        let factor = oldState.map { StepCalibration.factor(speed: $0.speed) } ?? 1
        self.calibratedStepTotal = (self.calibratedStepTotal ?? Double(self.steps)) + Double(stepDiff) * factor
        self.steps = self.steps + stepDiff
        self.distance = self.distance + distanceDiff
        self.walkingSeconds = self.walkingSeconds + walkingTimeDiff
        self.lastUpdateTime = newState.time
        
    }
    
    
    public func save() {
        let workoutData = WorkoutSaveData(steps: self.steps, distance: self.distance, walkingSeconds: self.walkingSeconds, date: self.lastUpdateTime,
                                          calibratedStepTotal: self.calibratedStepTotal)
        let withoutToday = loadAll().filter { !Calendar.current.isDateInToday($0.date)}
        let newData = withoutToday + [workoutData];
        
        let jsonEncoder = JSONEncoder()
        do {
            let json = try jsonEncoder.encode(WorkoutsSaveData(workouts: newData))
            FileSystem().save(filename: "workouts.json", data: json)
        } catch {
            print("could not save")
        }
    }
    
    public func load() {
        if (self.steps > 0) {
            return
        }
        let workouts = loadAll()
        let workout = workouts.first (where: { entry in Calendar.current.isDateInToday(entry.date) })
    
        if let foundWorkout = workout {
            self.steps = foundWorkout.steps
            self.calibratedStepTotal = foundWorkout.calibratedStepTotal
            self.distance = foundWorkout.distance
            self.walkingSeconds = foundWorkout.walkingSeconds
            self.lastUpdateTime = foundWorkout.date
        }
    }
    
    public func loadAll() -> [WorkoutSaveData] {
        let jsonDecoder = JSONDecoder()
        var workouts: [WorkoutSaveData] = []
        do {
            let optionalData = FileSystem().load(filename: "workouts.json")
            if let data = optionalData {
                let workoutData = try jsonDecoder.decode(WorkoutsSaveData.self, from: data)
                workouts = Array(workoutData.workouts.suffix(500))
            }
        } catch {
            print("Could not load workout data \(error)")
        }
        // Stats must include the live totals, even before the next save.
        if self.steps > 0 {
            workouts.removeAll { Calendar.current.isDate($0.date, inSameDayAs: self.lastUpdateTime) }
            workouts.append(WorkoutSaveData(steps: self.steps, distance: self.distance,
                                            walkingSeconds: self.walkingSeconds, date: self.lastUpdateTime,
                                            calibratedStepTotal: self.calibratedStepTotal))
        }
        return workouts
    }
    
    public func workoutState() -> WorkoutState {
        return WorkoutState(steps: self.steps, distance: self.distance, walkingSeconds: self.walkingSeconds)
    }
}
