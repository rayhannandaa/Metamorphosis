//
//  GameClock.swift
//  Gameplay
//

import CoreGraphics
import Foundation

final class GameClock {
    private(set) var currentDay: Int = 1
    private(set) var elapsedInDay: TimeInterval = 0
    private(set) var isDaytime: Bool = true
    private(set) var currentPhase: GamePhase = .worm
    private(set) var isGameComplete = false

    var onNewDay: ((Int) -> Void)?
    var onPhaseChange: ((GamePhase) -> Void)?
    var onDayNightChange: ((Bool) -> Void)?
    var onSunRayTick: ((Int) -> Void)?
    var onGameComplete: (() -> Void)?

    private var sunRayIndex = -1

    var displayTime: String {
        let hour: Int

        if isDaytime {
            let twoHourSlot = daylightSlotIndex
            hour = min(
                GameConfig.dayEndHour,
                GameConfig.dayStartHour +
                twoHourSlot * GameConfig.dayClockStepHours
            )
        } else {
            let nightElapsed = max(0, elapsedInDay - GameConfig.dayDuration)
            let oneHourSlot = min(
                GameConfig.nightClockSlotCount - 1,
                Int(
                    nightElapsed /
                    (GameConfig.nightDuration / Double(GameConfig.nightClockSlotCount))
                )
            )
            hour = (
                GameConfig.nightStartHour +
                oneHourSlot * GameConfig.nightClockStepHours
            ) % 24
        }

        return String(format: "%02d:00", hour)
    }

    func update(deltaTime: TimeInterval) {
        guard !isGameComplete, deltaTime > 0, deltaTime.isFinite else { return }

        elapsedInDay += deltaTime

        let wasDaytime = isDaytime
        isDaytime = elapsedInDay < GameConfig.dayDuration
        if isDaytime != wasDaytime {
            onDayNightChange?(isDaytime)
        }

        if isDaytime {
            updateSunRay()
        }

        if elapsedInDay >= GameConfig.cycleDuration {
            elapsedInDay = 0
            resetSunRayState()
            isDaytime = true
            advanceDay()
        }

        updatePhaseIfNeeded()
    }
    
    /// Skips the clock forward and publishes the resulting day and phase.
    func skipToDay(_ targetDay: Int) {
        currentDay = targetDay
        elapsedInDay = 0
        isDaytime = true
        resetSunRayState()
        updatePhaseIfNeeded()
        onDayNightChange?(isDaytime)
        onNewDay?(currentDay)
    }

    private func updateSunRay() {
        // 06:00 is a short grace period. From 08:00 onward, the ray index
        // advances from the exact same slot used by the displayed clock.
        let resolvedIndex = daylightSlotIndex - 1
        guard resolvedIndex >= 0,
              GameConfig.sunRayBottomOffsets.indices.contains(resolvedIndex),
              resolvedIndex != sunRayIndex
        else { return }

        sunRayIndex = resolvedIndex
        onSunRayTick?(resolvedIndex)
    }

    private func resetSunRayState() {
        sunRayIndex = -1
    }

    private var daylightSlotIndex: Int {
        let slotDuration =
            GameConfig.dayDuration /
            Double(GameConfig.dayClockSlotCount)

        return min(
            GameConfig.dayClockSlotCount - 1,
            Int(elapsedInDay / slotDuration)
        )
    }

    private func advanceDay() {
        currentDay += 1
        if currentDay > GameConfig.totalDemoDays {
            currentDay = GameConfig.totalDemoDays
            isGameComplete = true
            onGameComplete?()
            return
        }
        onDayNightChange?(isDaytime)
        onNewDay?(currentDay)
    }

    private func updatePhaseIfNeeded() {
        let resolved = resolvePhase()
        guard resolved != currentPhase else { return }
        currentPhase = resolved
        onPhaseChange?(resolved)
    }

    private func resolvePhase() -> GamePhase {
        switch currentDay {
        case 1:
            return .worm
        case 2:
            return .pupa
        default:
            return .butterfly
        }
    }
}
