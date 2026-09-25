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

    private var didShowFirstSunRay = false
    private var sunRayIndex = 0

    var displayTime: String {
        let hour: Int

        if isDaytime {
            let twoHourSlot = min(
                6,
                Int(elapsedInDay / ((GameConfig.dayDuration) / 6))
            )
            hour = min(
                18,
                GameConfig.dayStartHour +
                twoHourSlot * GameConfig.dayClockStepHours
            )
        } else {
            let nightElapsed = max(0, elapsedInDay - GameConfig.dayDuration)
            let oneHourSlot = min(
                5,
                Int(nightElapsed / (GameConfig.nightDuration / 5))
            )
            hour = (GameConfig.nightStartHour + oneHourSlot) % 24
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
        if !didShowFirstSunRay {
            guard elapsedInDay >= GameConfig.firstSunRayDelay else { return }
            didShowFirstSunRay = true
            sunRayIndex = 0
            onSunRayTick?(sunRayIndex)
            return
        }

        guard sunRayIndex < GameConfig.sunRayBottomOffsets.count - 1 else { return }

        let nextThreshold =
            GameConfig.firstSunRayDelay +
            TimeInterval(sunRayIndex + 1) * GameConfig.sunRayInterval

        if elapsedInDay >= nextThreshold {
            sunRayIndex += 1
            onSunRayTick?(sunRayIndex)
        }
    }

    private func resetSunRayState() {
        didShowFirstSunRay = false
        sunRayIndex = 0
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
