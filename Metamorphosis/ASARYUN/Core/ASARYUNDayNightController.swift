//
//  ASARYUNDayNightController.swift
//  ASARYUN
//
//  Owns the visual side of the day/night cycle. The sunlight is one
//  persistent trapezoid anchored beneath the window.
//

import SpriteKit

final class ASARYUNDayNightController {
    private weak var scene: SKScene?
    private let windowPosition: CGPoint
    private let windowSize: CGSize

    private weak var windowDay: SKSpriteNode?
    private weak var windowNight: SKSpriteNode?
    private let nightDim: SKSpriteNode
    private let sunRay: ASARYUNSunRayNode

    init(scene: SKScene, windowPosition: CGPoint, windowSize: CGSize, sceneSize: CGSize) {
        self.scene = scene
        self.windowPosition = windowPosition
        self.windowSize = windowSize

        windowDay = scene.childNode(withName: "//WindowDay") as? SKSpriteNode
        windowNight = scene.childNode(withName: "//WindowNight") as? SKSpriteNode
        windowDay?.alpha = 1
        windowNight?.alpha = 0

        nightDim = SKSpriteNode(
            color: SKColor(red: 0.03, green: 0.04, blue: 0.12, alpha: 0.55),
            size: sceneSize
        )
        nightDim.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        nightDim.zPosition = 10
        nightDim.alpha = 0
        nightDim.name = "ASARYUN_NightDim"

        sunRay = ASARYUNSunRayNode(
            topWidth: ASARYUNGameConfig.sunRayTopWidth,
            bottomWidth: ASARYUNGameConfig.sunRayBottomWidth,
            height: ASARYUNGameConfig.sunRayHeight
        )

        scene.addChild(sunRay)
        scene.addChild(nightDim)

        // Attach the beam's horizontal top edge to the bottom of the actual
        // window artwork. Fall back to the supplied window geometry if the
        // artwork is not present in the scene.
        let sourceWindow = windowDay ?? windowNight
        sunRay.position = CGPoint(
            x: sourceWindow?.frame.midX ?? windowPosition.x,
            y: sourceWindow?.frame.minY ?? (windowPosition.y - windowSize.height / 2)
        )
        sunRay.setBottomOffset(ASARYUNGameConfig.sunRayBottomOffsets[0], animated: false)
    }

    func setDaytime(_ isDaytime: Bool) {
        let duration = 0.75
        windowDay?.run(.fadeAlpha(to: isDaytime ? 1 : 0, duration: duration))
        windowNight?.run(.fadeAlpha(to: isDaytime ? 0 : 1, duration: duration))
        nightDim.run(.fadeAlpha(to: isDaytime ? 0 : 0.55, duration: duration))

        if isDaytime {
            // The clock will show the ray after the 12-second delay.
            // Do not show it immediately at the start of a new day.
            sunRay.hide()
        } else {
            sunRay.hide()
        }
    }

    /// Sweeps the wider bottom edge through five fixed positions while the
    /// top edge remains horizontal and attached to the window.
    func setSunRay(index: Int) {
        guard ASARYUNGameConfig.sunRayBottomOffsets.indices.contains(index) else { return }
        sunRay.setBottomOffset(ASARYUNGameConfig.sunRayBottomOffsets[index])
        sunRay.show()
    }

    func hideSunRay() {
        sunRay.hide()
    }

    func isPointInSunlight(_ scenePoint: CGPoint) -> Bool {
        sunRay.containsScenePoint(scenePoint)
    }
}
