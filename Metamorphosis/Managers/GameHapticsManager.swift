//
//  GameHapticsManager.swift
//  Metamorphosis
//
//  Retains and prepares the haptic engine so important gameplay feedback is
//  not lost while a temporary UIKit feedback generator is warming up.
//

import CoreHaptics
import UIKit

@MainActor
final class GameHapticsManager {
    static let shared = GameHapticsManager()

    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    private let warningGenerator = UINotificationFeedbackGenerator()
    private let fallbackImpactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private var engine: CHHapticEngine?
    private var dangerPlayer: CHHapticPatternPlayer?

    private init() {}

    func prepare() {
        warningGenerator.prepare()
        fallbackImpactGenerator.prepare()

        guard supportsHaptics else { return }

        do {
            if engine == nil {
                engine = try CHHapticEngine()
                engine?.playsHapticsOnly = true
            }
            try engine?.start()
        } catch {
            engine = nil
            print("Unable to prepare Core Haptics engine: \(error)")
        }
    }

    func playDangerWarning() {
        // UIKit's error pattern is the primary feedback and remains the most
        // reliable option across physical iPhone models and engine restarts.
        warningGenerator.notificationOccurred(.error)
        warningGenerator.prepare()

        guard supportsHaptics else {
            playFallbackImpact()
            return
        }

        prepare()

        let strongThump = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
            ],
            relativeTime: 0
        )
        let followUpThump = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            ],
            relativeTime: 0.16
        )

        do {
            let pattern = try CHHapticPattern(
                events: [strongThump, followUpThump],
                parameters: []
            )
            dangerPlayer = try engine?.makePlayer(with: pattern)
            try dangerPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Unable to play Core Haptics danger warning: \(error)")
            playFallbackImpact()
        }
    }

    private func playFallbackImpact() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [fallbackImpactGenerator] in
            fallbackImpactGenerator.impactOccurred(intensity: 1)
            fallbackImpactGenerator.prepare()
        }
    }
}
