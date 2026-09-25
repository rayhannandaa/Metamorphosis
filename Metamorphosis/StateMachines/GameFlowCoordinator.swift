import Combine

enum GameFlowState: Equatable {
    case loading
    case openingIntro
    case larvaDialogue
    case playing
    case cocoonCutscene
    case butterflyDialogue
    case escapeDialogue
    case escaping

    var blocksGameplayControls: Bool {
        switch self {
        case .loading, .openingIntro, .larvaDialogue,
             .butterflyDialogue, .escapeDialogue, .escaping:
            true
        case .playing, .cocoonCutscene:
            false
        }
    }
}

@MainActor
final class GameFlowCoordinator: ObservableObject {
    @Published private(set) var state: GameFlowState = .loading

    func transition(to newState: GameFlowState) {
        guard state != newState else { return }
        state = newState
    }
}
