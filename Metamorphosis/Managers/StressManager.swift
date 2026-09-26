//
//  StressManager.swift
//  Gameplay
//
//  Stress rises whenever the worm is caught by a ray of sunlight, and
//  slowly cools back down while it stays in the shade.
//

import CoreGraphics
import Foundation

final class StressManager {
    private(set) var value: CGFloat = 0
    var onChange: ((CGFloat) -> Void)?

    func registerSunHit() {
        let updated = min(GameConfig.maxBarValue, value + GameConfig.stressIncreasePerSunHit)
        guard updated != value else { return }
        value = updated
        onChange?(value)
    }

    func update(deltaTime: TimeInterval, decayPerSecond: CGFloat) {
        guard value > 0 else { return }
        value = max(0, value - decayPerSecond * CGFloat(deltaTime))
        onChange?(value)
    }

    func reset() {
        value = 0
        onChange?(value)
    }
}
