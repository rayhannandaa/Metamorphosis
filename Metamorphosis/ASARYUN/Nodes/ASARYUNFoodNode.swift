//
//  ASARYUNFoodNode.swift
//  ASARYUN
//
//  A small piece of food the worm can find while exploring the room.
//  Uses the generated "ASARYUN_Food" texture (Assets.xcassets/ASARYUN).
//

import SpriteKit

final class ASARYUNFoodNode: SKSpriteNode {
    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: "ASARYUN_Food")
        super.init(texture: texture, color: .clear, size: CGSize(width: 26, height: 26))
        self.position = position
        name = "ASARYUN_Food"
        zPosition = 2.6

        physicsBody = SKPhysicsBody(circleOfRadius: 13)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = ASARYUNPhysicsCategory.food
        physicsBody?.contactTestBitMask = ASARYUNPhysicsCategory.player
        physicsBody?.collisionBitMask = 0

        run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 4, duration: 0.6),
            .moveBy(x: 0, y: -4, duration: 0.6)
        ])))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
