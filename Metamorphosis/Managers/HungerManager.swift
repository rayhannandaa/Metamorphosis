//
//  HungerManager.swift
//  Gameplay
//
//  Hunger drains while the worm is exploring the room, and is restored
//  by finding and eating food scattered around the room.
//

import CoreGraphics
import Foundation

final class HungerManager {
    private(set) var value: CGFloat = GameConfig.initialHungerValue
    var onChange: ((CGFloat) -> Void)?
    var onStarving: (() -> Void)?

    private var didNotifyStarving = false
    private var graceTimeRemaining = GameConfig.hungerGracePeriod

    func update(deltaTime: TimeInterval) {
        guard value > 0 else { return }

        var depletionTime = deltaTime
        if graceTimeRemaining > 0 {
            let elapsedGraceTime = min(graceTimeRemaining, depletionTime)
            graceTimeRemaining -= elapsedGraceTime
            depletionTime -= elapsedGraceTime
        }

        guard depletionTime > 0 else { return }

        value = max(0, value - GameConfig.hungerDepletionPerSecond * CGFloat(depletionTime))
        onChange?(value)
        if value == 0, !didNotifyStarving {
            didNotifyStarving = true
            onStarving?()
        }
    }

    func feed() {
        graceTimeRemaining = GameConfig.hungerGracePeriod
        let updated = min(GameConfig.maxBarValue, value + GameConfig.hungerRestoreOnFood)
        guard updated != value else { return }
        value = updated
        didNotifyStarving = false
        onChange?(value)
    }

    func reset() {
        value = GameConfig.initialHungerValue
        graceTimeRemaining = GameConfig.hungerGracePeriod
        didNotifyStarving = false
        onChange?(value)
    }
}
