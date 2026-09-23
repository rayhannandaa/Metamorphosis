//
//  ASARYUNDayNightController.swift
//  ASARYUN
//
//  Owns the visual side of the day/night cycle. The sunlight is one
//  persistent node anchored to the CENTER of the window.
//

import SpriteKit

final class ASARYUNDayNightController {
    private weak var scene: SKScene?
    private let windowPosition: CGPoint
    private let windowSize: CGSize

    private let nightSky: SKSpriteNode
    private let nightDim: SKSpriteNode
    private let sunRay: ASARYUNSunRayNode

    init(scene: SKScene, windowPosition: CGPoint, windowSize: CGSize, sceneSize: CGSize) {
        self.scene = scene
        self.windowPosition = windowPosition
        self.windowSize = windowSize

        nightSky = SKSpriteNode(imageNamed: "ASARYUN_NightSky")
        nightSky.size = windowSize
        nightSky.position = windowPosition
        nightSky.zPosition = 2.05
        nightSky.alpha = 0
        nightSky.name = "ASARYUN_NightSky"

        nightDim = SKSpriteNode(
            color: SKColor(red: 0.03, green: 0.04, blue: 0.12, alpha: 0.55),
            size: sceneSize
        )
        nightDim.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        nightDim.zPosition = 10
        nightDim.alpha = 0
        nightDim.name = "ASARYUN_NightDim"

        sunRay = ASARYUNSunRayNode(size: ASARYUNGameConfig.sunRaySize)

        scene.addChild(nightSky)
        scene.addChild(sunRay)
        scene.addChild(nightDim)

        // Center of the actual window — no rightward drift.
        sunRay.position = windowPosition
        sunRay.setAngle(ASARYUNGameConfig.sunRayAngles[0], animated: false)
    }

    func setDaytime(_ isDaytime: Bool) {
        let duration = 0.75
        nightSky.run(.fadeAlpha(to: isDaytime ? 0 : 1, duration: duration))
        nightDim.run(.fadeAlpha(to: isDaytime ? 0 : 0.55, duration: duration))

        if isDaytime {
            // The clock will show the ray after the 12-second delay.
            // Do not show it immediately at the start of a new day.
            sunRay.hide()
        } else {
            sunRay.hide()
        }
    }

    /// Moves the same ray through the five fixed positions. The ray remains
    /// centered in the window for its entire lifetime.
    func setSunRay(index: Int) {
        guard ASARYUNGameConfig.sunRayAngles.indices.contains(index) else { return }
        sunRay.position = windowPosition
        sunRay.setAngle(ASARYUNGameConfig.sunRayAngles[index])
        sunRay.show()
    }

    func hideSunRay() {
        sunRay.hide()
    }
}
