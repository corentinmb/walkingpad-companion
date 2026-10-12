import SwiftUI

struct FooterView: View {
    @EnvironmentObject var walkingPadService: WalkingPadService
    @EnvironmentObject var workout: Workout
    @Environment(\.openURL) var openURL

    var body: some View {
        HStack {
            Button { openURL(URL(string: "https://walkingpad-stats.netlify.app")!) } label: {
                Label("Stats", systemImage: "chart.bar.xaxis")
            }
            Spacer()
            LoginLogoutButton()
            Spacer()
            Button {
                walkingPadService.command()?.setSpeed(speed: 0)
                workout.save()
                exit(0)
            } label: {
                Label("Quit", systemImage: "power")
            }
        }
        .buttonStyle(WalkingpadQuietButtonStyle())
    }
}
