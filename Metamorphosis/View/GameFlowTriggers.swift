import SwiftUI

struct EscapeRequestTrigger: View {
    @ObservedObject var session: GameSessionController
    let onEscapeRequested: () -> Void

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .onChange(of: session.isEscapeRequested, initial: true) { _, isRequested in
                guard isRequested else { return }
                onEscapeRequested()
            }
    }
}

struct DayTwoCutsceneTrigger: View {
    @ObservedObject var session: GameSessionController
    let onDayTwo: () -> Void

    @State private var hasTriggered = false

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .onChange(of: session.day, initial: true) { _, newDay in
                guard newDay == 2, !hasTriggered else { return }
                hasTriggered = true
                onDayTwo()
            }
    }
}
