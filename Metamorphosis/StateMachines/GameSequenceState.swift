enum GameSequenceState: Equatable {
    case introduction
    case playing
    case cocoonCutscene
    case butterflyDialogue
    case escapeDialogue
    case escaping

    var blocksGameplayControls: Bool {
        switch self {
        case .butterflyDialogue, .escapeDialogue, .escaping:
            true
        case .introduction, .playing, .cocoonCutscene:
            false
        }
    }
}
