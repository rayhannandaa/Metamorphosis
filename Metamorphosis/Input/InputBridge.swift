import Combine

final class InputBridge: ObservableObject {
    @Published var controlsEnabled = true {
        didSet {
            if !controlsEnabled {
                cancelMovement()
            }
        }
    }

    private weak var scene: RoomScene?

    init(scene: RoomScene) {
        self.scene = scene
    }

    func pressedDirection(_ direction: MovementDirection) {
        guard controlsEnabled else { return }
        scene?.setMovementDirection(direction, isActive: true)
    }

    func releasedDirection(_ direction: MovementDirection) {
        scene?.setMovementDirection(direction, isActive: false)
    }

    func quickTappedDirection(_ direction: MovementDirection) {
        guard controlsEnabled else { return }
        scene?.advanceWormStepFrame(direction)
    }

    func tappedInteract() {
        guard controlsEnabled, let scene else { return }
        scene.interactableManager.triggerInteraction(
            phase: scene.session.phase,
            isDaytime: scene.session.isDaytime
        )
    }

    func cancelMovement() {
        scene?.stopAllMovement()
    }
}
