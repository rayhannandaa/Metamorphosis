import Combine
import CoreMotion
import Foundation

@MainActor
final class SustainedShakeDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    private let requiredDuration: TimeInterval = 1.2
    private let accelerationThreshold = 0.65
    private let permittedPause: TimeInterval = 0.28

    private var firstStrongMotionTime: TimeInterval?
    private var lastStrongMotionTime: TimeInterval?
    private var hasTriggered = false
    private var onShake: (() -> Void)?

    func start(onShake: @escaping () -> Void) {
        stop()
        guard motionManager.isDeviceMotionAvailable else { return }

        self.onShake = onShake
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let acceleration = motion?.userAcceleration else { return }

            let magnitude = sqrt(
                acceleration.x * acceleration.x
                    + acceleration.y * acceleration.y
                    + acceleration.z * acceleration.z
            )
            self.process(magnitude: magnitude)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        firstStrongMotionTime = nil
        lastStrongMotionTime = nil
        hasTriggered = false
        onShake = nil
    }

    private func process(magnitude: Double) {
        guard !hasTriggered else { return }
        let now = ProcessInfo.processInfo.systemUptime

        if magnitude >= accelerationThreshold {
            if let lastStrongMotionTime,
               now - lastStrongMotionTime > permittedPause {
                firstStrongMotionTime = now
            } else if firstStrongMotionTime == nil {
                firstStrongMotionTime = now
            }

            lastStrongMotionTime = now

            if let firstStrongMotionTime,
               now - firstStrongMotionTime >= requiredDuration {
                hasTriggered = true
                let completion = onShake
                stop()
                completion?()
            }
        } else if let lastStrongMotionTime,
                  now - lastStrongMotionTime > permittedPause {
            firstStrongMotionTime = nil
            self.lastStrongMotionTime = nil
        }
    }
}
