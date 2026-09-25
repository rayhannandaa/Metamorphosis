//
//  DeathManager.swift
//  Metamorphosis
//
//  Tracks critical survival values and gives the player a short chance
//  to recover before a lethal stress or hunger value causes Game Over.
//

import CoreGraphics
import Foundation

enum DeathCause: Equatable {
    case stress
    case hunger

    var message: String {
        switch self {
        case .stress:
            return "The light became too overwhelming."
        case .hunger:
            return "The larva could not survive without food."
        }
    }
}

struct DeathStatus {
    let isWarning: Bool
    let isCountdownActive: Bool
    let cause: DeathCause?
    let didDie: Bool
}

final class DeathManager {
    private var lethalTime: TimeInterval = 0

    func update(
        stress: CGFloat,
        hunger: CGFloat,
        monitorsHunger: Bool,
        deltaTime: TimeInterval
    ) -> DeathStatus {
        let stressIsCritical = stress >= GameConfig.stressWarningThreshold
        let hungerIsCritical = monitorsHunger && hunger <= GameConfig.hungerWarningThreshold
        let cause = lethalCause(
            stress: stress,
            hunger: hunger,
            monitorsHunger: monitorsHunger
        )

        if cause == nil {
            lethalTime = 0
        } else {
            lethalTime += deltaTime
        }

        return DeathStatus(
            isWarning: stressIsCritical || hungerIsCritical,
            isCountdownActive: cause != nil,
            cause: cause,
            didDie: lethalTime >= GameConfig.deathDelay
        )
    }

    func reset() {
        lethalTime = 0
    }

    private func lethalCause(
        stress: CGFloat,
        hunger: CGFloat,
        monitorsHunger: Bool
    ) -> DeathCause? {
        if stress >= GameConfig.maxBarValue {
            return .stress
        }
        if monitorsHunger, hunger <= 0 {
            return .hunger
        }
        return nil
    }
}
