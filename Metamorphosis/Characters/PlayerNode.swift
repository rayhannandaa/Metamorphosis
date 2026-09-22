//
//  PlayerNode.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 22/09/26.
//


// Characters/PlayerNode.swift
import SpriteKit

final class PlayerNode: SKSpriteNode {
    private let config: PlayerConfig
    private let texturesByDirection: [MovementDirection: [SKTexture]]
    private var currentFacing: MovementDirection
    private var isWalking = false

    init(config: PlayerConfig) {
        self.config = config
        self.currentFacing = config.initialFacing

        var cache: [MovementDirection: [SKTexture]] = [:]
        for direction in MovementDirection.allCases {
            cache[direction] = (0..<config.frameCount).map { frameIndex in
                let texture = SKTexture(imageNamed: "\(config.assetPrefix)_\(direction.compassCode)_\(frameIndex)")
                texture.filteringMode = .nearest // keep pixel art crisp when scaled
                return texture
            }
        }
        self.texturesByDirection = cache

        let idleTexture = cache[config.initialFacing]?[config.idleFrameIndex]
        super.init(texture: idleTexture, color: .clear, size: config.size)
        name = "Player"
        position = config.initialPosition
        zPosition = config.zPosition
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func move(by translation: CGVector, facing: MovementDirection) {
        position.x += translation.dx
        position.y += translation.dy
        updateAnimation(facing: facing, isWalking: true)
    }

    func stopWalking() {
        updateAnimation(facing: currentFacing, isWalking: false)
    }

    private func updateAnimation(facing: MovementDirection, isWalking: Bool) {
        let facingChanged = facing != currentFacing
        let walkStateChanged = isWalking != self.isWalking
        currentFacing = facing
        self.isWalking = isWalking

        guard facingChanged || walkStateChanged else { return }

        guard isWalking, let frames = texturesByDirection[facing] else {
            texture = texturesByDirection[facing]?[config.idleFrameIndex]
            removeAction(forKey: "walk")
            return
        }

        run(.repeatForever(.animate(with: frames, timePerFrame: config.frameDuration)), withKey: "walk")
    }
}
