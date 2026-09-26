//
//  FoodNode.swift
//  Gameplay
//
//  A piece of food the worm can find while exploring the room.
//

import SpriteKit

enum FoodKind: CaseIterable {
    case watermelon
    case cheese

    var assetName: String {
        switch self {
        case .watermelon: return "Watermelon"
        case .cheese: return "Cheese"
        }
    }

    var size: CGSize {
        switch self {
        case .watermelon: return CGSize(width: 26, height: 26)
        case .cheese: return CGSize(width: 26, height: 25)
        }
    }
}

final class FoodNode: SKSpriteNode {
    init(position: CGPoint, kind: FoodKind) {
        let texture = SKTexture(imageNamed: kind.assetName)
        super.init(texture: texture, color: .clear, size: kind.size)
        self.position = position
        name = "Food_\(kind.assetName)"
        zPosition = 2.6

        physicsBody = SKPhysicsBody(circleOfRadius: min(kind.size.width, kind.size.height) / 2)
        physicsBody?.isDynamic = false
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = PhysicsCategory.food
        physicsBody?.contactTestBitMask = PhysicsCategory.player
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
