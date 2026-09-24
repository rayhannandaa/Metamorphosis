//
//  ASARYUNStressManager.swift
//  ASARYUN
//
//  Stress rises whenever the worm is caught by a ray of sunlight, and
//  slowly cools back down while it stays in the shade.
//

import CoreGraphics
import Foundation

final class ASARYUNStressManager {
    private(set) var value: CGFloat = 0
    var onChange: ((CGFloat) -> Void)?

    func registerSunHit() {
        let updated = min(ASARYUNGameConfig.maxBarValue, value + ASARYUNGameConfig.stressIncreasePerSunHit)
        guard updated != value else { return }
        value = updated
        onChange?(value)
    }

    func update(deltaTime: TimeInterval) {
        guard value > 0 else { return }
        value = max(0, value - ASARYUNGameConfig.stressDecayPerSecond * CGFloat(deltaTime))
        onChange?(value)
    }

    func reset() {
        value = 0
        onChange?(value)
    }
}
