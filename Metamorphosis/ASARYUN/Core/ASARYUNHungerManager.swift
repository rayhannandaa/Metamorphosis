//
//  ASARYUNHungerManager.swift
//  ASARYUN
//
//  Hunger drains while the worm is exploring the room, and is restored
//  by finding and eating food scattered around the room.
//

import CoreGraphics
import Foundation

final class ASARYUNHungerManager {
    private(set) var value: CGFloat = ASARYUNGameConfig.initialHungerValue
    var onChange: ((CGFloat) -> Void)?
    var onStarving: (() -> Void)?

    private var didNotifyStarving = false
    private var graceTimeRemaining = ASARYUNGameConfig.hungerGracePeriod

    func update(deltaTime: TimeInterval) {
        guard value > 0 else { return }

        var depletionTime = deltaTime
        if graceTimeRemaining > 0 {
            let elapsedGraceTime = min(graceTimeRemaining, depletionTime)
            graceTimeRemaining -= elapsedGraceTime
            depletionTime -= elapsedGraceTime
        }

        guard depletionTime > 0 else { return }

        value = max(0, value - ASARYUNGameConfig.hungerDepletionPerSecond * CGFloat(depletionTime))
        onChange?(value)
        if value == 0, !didNotifyStarving {
            didNotifyStarving = true
            onStarving?()
        }
    }

    func feed() {
        graceTimeRemaining = ASARYUNGameConfig.hungerGracePeriod
        let updated = min(ASARYUNGameConfig.maxBarValue, value + ASARYUNGameConfig.hungerRestoreOnFood)
        guard updated != value else { return }
        value = updated
        didNotifyStarving = false
        onChange?(value)
    }

    func reset() {
        value = ASARYUNGameConfig.initialHungerValue
        graceTimeRemaining = ASARYUNGameConfig.hungerGracePeriod
        didNotifyStarving = false
        onChange?(value)
    }
}
