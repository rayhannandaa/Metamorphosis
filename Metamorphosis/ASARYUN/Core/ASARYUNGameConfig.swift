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
    /// Five stable positions across the daylight period. The beam's top
    /// remains attached to the window while its wider bottom edge sweeps
    /// horizontally, like a lighthouse beam.
    static let sunRayInterval: TimeInterval = 18
    static let sunRayTransitionDuration: TimeInterval = 0.75
    static let sunRayAlpha: CGFloat = 0.55
    static let sunRayEdgeBlurRadius: CGFloat = 15

    /// The top edge matches the 60-point-wide day/night window artwork.
    /// The bottom edge is deliberately wider to create the light spread.
    static let sunRayTopWidth: CGFloat = 60
    static let sunRayBottomWidth: CGFloat = 120
    static let sunRayHeight: CGFloat = 460
    static let sunRayBottomCurveDepth: CGFloat = 30
    static let sunRayBottomOffsets: [CGFloat] = [-110, -55, 0, 55, 110]

    // MARK: Demo length
    static let totalDemoDays = 3

    // MARK: Bars
    static let maxBarValue: CGFloat = 100
    static let initialHungerValue: CGFloat = 25
    static let stressIncreasePerSunHit: CGFloat = 18
    static let stressSunIntervalSeconds: TimeInterval = 1.25
    static let stressDecayPerSecond: CGFloat = 1.5
    static let hungerDepletionPerSecond: CGFloat = (maxBarValue / 2) / CGFloat(cycleDuration)
    static let hungerRestoreOnFood: CGFloat = 30
    static let foodPerDay = 4
    static let foodSpawnClearance: CGFloat = 6
    static let foodSpawnMaxAttempts = 100

    // MARK: HUD refresh
    /// The game keeps running at the normal SpriteKit frame rate, but the
    /// SwiftUI HUD does not need to publish every frame.
    static let hudUpdateInterval: TimeInterval = 0.15
}
