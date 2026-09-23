//
//  ASARYUNGameConfig.swift
//  ASARYUN
//
//  Tunable numbers for the day/night cycle, stress, hunger and the
//  demo's compressed 3-day game length. Nothing here touches the
//  existing Metamorphosis code — change these freely to retune.
//

import CoreGraphics
import Foundation

enum ASARYUNGameConfig {
    // MARK: Day / night length
    /// The complete in-game day + night cycle is 3 minutes.
    /// Day: 06:00–18:00 (90 seconds).
    /// Night: 19:00–00:00 (90 seconds).
    static let dayDuration: TimeInterval = 90
    static let nightDuration: TimeInterval = 90
    static var cycleDuration: TimeInterval { dayDuration + nightDuration }

    // MARK: In-game clock
    /// Clock display starts at 06:00 each day.
    static let dayStartHour = 6
    /// Clock display advances in 2-hour steps: 06, 08, 10, ... 18.
    static let dayClockStepHours = 2
    /// Clock display starts at 19:00 at night and advances hourly to 00:00.
    static let nightStartHour = 19
    static let nightClockStepHours = 1

    // MARK: Sunlight ray
    /// The first sunlight appears 12 seconds after 06:00.
    static let firstSunRayDelay: TimeInterval = 12
    /// Five stable positions across the daylight period:
    /// full "/", slight "/", "|", slight "\", full "\".
    /// The ray stays at each position until the next interval.
    static let sunRayInterval: TimeInterval = 18
    static let sunRayTransitionDuration: TimeInterval = 0.75
    static let sunRayAlpha: CGFloat = 0.55

    /// Rotation angles, in order:
    /// full "/" -> slight "/" -> "|" -> slight "\" -> full "\".
    static let sunRayAngles: [CGFloat] = [
        -35 * .pi / 180,
        -17.5 * .pi / 180,
        0,
        17.5 * .pi / 180,
        35 * .pi / 180
    ]

    /// Ray size. The ray is anchored to the center of the window.
    static let sunRaySize = CGSize(width: 70, height: 460)

    // MARK: Demo length
    static let totalDemoDays = 3

    // MARK: Bars
    static let maxBarValue: CGFloat = 100
    static let stressIncreasePerSunHit: CGFloat = 18
    static let stressSunIntervalSeconds: TimeInterval = 2.5
    static let stressDecayPerSecond: CGFloat = 1.5
    static let hungerDepletionPerSecond: CGFloat = (maxBarValue / 2) / CGFloat(cycleDuration)
    static let hungerRestoreOnFood: CGFloat = 30
    static let foodPerDay = 4

    // MARK: HUD refresh
    /// The game keeps running at the normal SpriteKit frame rate, but the
    /// SwiftUI HUD does not need to publish every frame.
    static let hudUpdateInterval: TimeInterval = 0.15
}
