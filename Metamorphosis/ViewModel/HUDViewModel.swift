import Combine

final class HUDViewModel: ObservableObject {
    private let input: InputBridge

    init(input: InputBridge) {
        self.input = input
    }

    func setControlsEnabled(_ isEnabled: Bool) {
        input.controlsEnabled = isEnabled
    }

    func handlePress(for button: HUDButtonConfig) {
        if let direction = button.direction {
            input.pressedDirection(direction)
        } else if button.name == "ActionButton" {
            input.tappedInteract()
        }
    }

    func handleRelease(for button: HUDButtonConfig) {
        guard let direction = button.direction else { return }
        input.releasedDirection(direction)
    }

    func handleQuickTap(for button: HUDButtonConfig) {
        guard let direction = button.direction else { return }
        input.quickTappedDirection(direction)
    }
}
