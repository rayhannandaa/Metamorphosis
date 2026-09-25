//
//  ASARYUNDeathManager.swift
//  Metamorphosis
//
//  Tracks critical survival values and gives the player a short chance
//  to recover before a lethal stress or hunger value causes Game Over.
//

import CoreGraphics
import Foundation

enum ASARYUNDeathCause: Equatable {
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

struct ASARYUNDeathStatus {
    let isWarning: Bool
    let isCountdownActive: Bool
    let cause: ASARYUNDeathCause?
    let didDie: Bool
}

final class ASARYUNDeathManager {
    private var lethalTime: TimeInterval = 0

    func update(
        stress: CGFloat,
        hunger: CGFloat,
        monitorsHunger: Bool,
        deltaTime: TimeInterval
    ) -> ASARYUNDeathStatus {
        let stressIsCritical = stress >= ASARYUNGameConfig.stressWarningThreshold
        let hungerIsCritical = monitorsHunger && hunger <= ASARYUNGameConfig.hungerWarningThreshold
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

        return ASARYUNDeathStatus(
            isWarning: stressIsCritical || hungerIsCritical,
            isCountdownActive: cause != nil,
            cause: cause,
            didDie: lethalTime >= ASARYUNGameConfig.deathDelay
        )
    }

    func reset() {
        lethalTime = 0
    }

    private func lethalCause(
        stress: CGFloat,
        hunger: CGFloat,
        monitorsHunger: Bool
    ) -> ASARYUNDeathCause? {
        if stress >= ASARYUNGameConfig.maxBarValue {
            return .stress
        }
        if monitorsHunger, hunger <= 0 {
            return .hunger
        }
        return nil
    }
}
