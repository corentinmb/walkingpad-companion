import Foundation

struct WorkoutSaveData: Codable {
    var steps: Int
    var distance: Int
    var walkingSeconds: Int
    var date: Date
    var calibratedStepTotal: Double? = nil
}


struct WorkoutsSaveData: Codable {
    var workouts: [WorkoutSaveData]
}
