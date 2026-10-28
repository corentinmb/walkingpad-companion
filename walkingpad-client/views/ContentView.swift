import SwiftUI

struct ContentView: View {
    @EnvironmentObject var walkingPadService: WalkingPadService
    @EnvironmentObject var workout: Workout
    @AppStorage("dailyStepGoal") private var dailyStepGoal = WorkoutSummary.defaultGoal

    var body: some View {
        MenuBarPanel(
            summary: WorkoutSummary(steps: workout.calibratedSteps, distance: workout.distance,
                                    walkingSeconds: workout.walkingSeconds, rawSteps: workout.steps),
            connected: walkingPadService.isConnected(),
            device: walkingPadService.lastStatus(),
            dailyStepGoal: $dailyStepGoal,
            startOrStop: {
                guard walkingPadService.isConnected(), let state = walkingPadService.lastStatus() else { return }
                if state.speed > 0 { walkingPadService.command()?.setSpeed(speed: 0) }
                else { walkingPadService.command()?.start() }
            },
            changeSpeed: { delta in
                guard let speed = SpeedControlPolicy.targetSpeed(from: walkingPadService.lastStatus(),
                    connected: walkingPadService.isConnected(), delta: delta) else { return }
                walkingPadService.command()?.setSpeed(speed: speed)
            },
            changeMode: { mode in
                guard walkingPadService.isConnected(), walkingPadService.lastStatus() != nil else { return }
                walkingPadService.command()?.setWalkingMode(mode: mode)
            },
            footer: { FooterView() }
        )
    }
}
