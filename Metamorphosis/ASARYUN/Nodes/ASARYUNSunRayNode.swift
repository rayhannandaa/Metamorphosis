//
//  ASARYUNSunRayNode.swift
//  ASARYUN
//
//  A single persistent beam of light anchored at the CENTER of the window.
//  It does not travel or get recreated. During the day it changes angle at
//  fixed intervals: "/" -> slight "/" -> "|" -> slight "\" -> "\".
//

import SpriteKit

final class ASARYUNSunRayNode: SKSpriteNode {
    init(size: CGSize) {
        let texture = SKTexture(imageNamed: "ASARYUN_SunRay")
        super.init(texture: texture, color: .clear, size: size)

        name = "ASARYUN_SunRay"
        alpha = 0
        zPosition = 4

        // The ray is pinned at its top edge. Its position is set to the
        // center of the window by ASARYUNDayNightController.
        anchorPoint = CGPoint(x: 0.5, y: 1.0)

        physicsBody = SKPhysicsBody(
            rectangleOf: size,
            center: CGPoint(x: 0, y: -size.height / 2)
        )
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = 0
        physicsBody?.contactTestBitMask = ASARYUNPhysicsCategory.player
        physicsBody?.collisionBitMask = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Places the ray at one of the five fixed daylight angles.
    /// The node itself never translates, so the sunlight always comes from
    /// exactly the same point in the window.
    func setAngle(_ angle: CGFloat, animated: Bool = true) {
        removeAction(forKey: "ASARYUNSunRayRotation")

        if animated {
            run(
                .rotate(toAngle: angle, duration: ASARYUNGameConfig.sunRayTransitionDuration),
                withKey: "ASARYUNSunRayRotation"
            )
        } else {
            zRotation = angle
        }
    }

    func show() {
        physicsBody?.categoryBitMask = ASARYUNPhysicsCategory.sunRay
        guard alpha < ASARYUNGameConfig.sunRayAlpha else { return }
        run(
            .fadeAlpha(
                to: ASARYUNGameConfig.sunRayAlpha,
                duration: ASARYUNGameConfig.sunRayTransitionDuration
            ),
            withKey: "ASARYUNSunRayFade"
        )
    }

    func hide() {
        physicsBody?.categoryBitMask = 0
        removeAction(forKey: "ASARYUNSunRayFade")
        run(.fadeOut(withDuration: 0.5), withKey: "ASARYUNSunRayFade")
    }
}
