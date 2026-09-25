//
//  ASARYUNGameClock.swift
//  ASARYUN
//

import CoreGraphics
import Foundation

final class ASARYUNGameClock {
    private(set) var currentDay: Int = 1
    private(set) var elapsedInDay: TimeInterval = 0
    private(set) var isDaytime: Bool = true
    private(set) var currentPhase: ASARYUNGamePhase = .worm
    private(set) var isGameComplete = false

    var onNewDay: ((Int) -> Void)?
    var onPhaseChange: ((ASARYUNGamePhase) -> Void)?
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
                Int(elapsedInDay / ((ASARYUNGameConfig.dayDuration) / 6))
            )
            hour = min(
                18,
                ASARYUNGameConfig.dayStartHour +
                twoHourSlot * ASARYUNGameConfig.dayClockStepHours
            )
        } else {
            let nightElapsed = max(0, elapsedInDay - ASARYUNGameConfig.dayDuration)
            let oneHourSlot = min(
                5,
                Int(nightElapsed / (ASARYUNGameConfig.nightDuration / 5))
            )
            hour = (ASARYUNGameConfig.nightStartHour + oneHourSlot) % 24
        }

        return String(format: "%02d:00", hour)
    }

    func update(deltaTime: TimeInterval) {
        guard !isGameComplete, deltaTime > 0, deltaTime.isFinite else { return }

        elapsedInDay += deltaTime

        let wasDaytime = isDaytime
        isDaytime = elapsedInDay < ASARYUNGameConfig.dayDuration
        if isDaytime != wasDaytime {
            onDayNightChange?(isDaytime)
        }

        if isDaytime {
            updateSunRay()
        }

        if elapsedInDay >= ASARYUNGameConfig.cycleDuration {
            elapsedInDay = 0
            resetSunRayState()
            isDaytime = true
            advanceDay()
        }

        updatePhaseIfNeeded()
    }
    
    // NEW MECHANIC: Skips the clock forward instantly and triggers necessary callbacks
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
            guard elapsedInDay >= ASARYUNGameConfig.firstSunRayDelay else { return }
            didShowFirstSunRay = true
            sunRayIndex = 0
            onSunRayTick?(sunRayIndex)
            return
        }

        guard sunRayIndex < ASARYUNGameConfig.sunRayBottomOffsets.count - 1 else { return }

        let nextThreshold =
            ASARYUNGameConfig.firstSunRayDelay +
            TimeInterval(sunRayIndex + 1) * ASARYUNGameConfig.sunRayInterval

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
        if currentDay > ASARYUNGameConfig.totalDemoDays {
            currentDay = ASARYUNGameConfig.totalDemoDays
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

    private func resolvePhase() -> ASARYUNGamePhase {
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
