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
    private(set) var value: CGFloat = ASARYUNGameConfig.maxBarValue
    var onChange: ((CGFloat) -> Void)?
    var onStarving: (() -> Void)?

    private var didNotifyStarving = false

    func update(deltaTime: TimeInterval) {
        guard value > 0 else { return }
        value = max(0, value - ASARYUNGameConfig.hungerDepletionPerSecond * CGFloat(deltaTime))
        onChange?(value)
        if value == 0, !didNotifyStarving {
            didNotifyStarving = true
            onStarving?()
        }
    }

    func feed() {
        let updated = min(ASARYUNGameConfig.maxBarValue, value + ASARYUNGameConfig.hungerRestoreOnFood)
        guard updated != value else { return }
        value = updated
        didNotifyStarving = false
        onChange?(value)
    }

    func reset() {
        value = ASARYUNGameConfig.maxBarValue
        didNotifyStarving = false
        onChange?(value)
    }
}
