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
        print("Workout stats regression checks passed")
    }
}
