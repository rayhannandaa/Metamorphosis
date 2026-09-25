// Characters/PlayerNode.swift
import SpriteKit

final class PlayerNode: SKSpriteNode {
    private let config: PlayerConfig
    private var currentFacing: MovementDirection
    private var isWalking = false
    
    // Now listens to the game's actual phase instead of a detached integer
    var currentPhase: ASARYUNGamePhase = .worm {
        didSet {
            updateAnimation(facing: currentFacing, isWalking: isWalking, forceUpdate: true)
        }
    }

    init(config: PlayerConfig) {
        self.config = config
        self.currentFacing = config.initialFacing

        let initialDirection = Self.textureDirectionUsingNorthForVertical(config.initialFacing)
        let initialTexture = SKTexture(imageNamed: "Worm_\(initialDirection)_0")
        initialTexture.filteringMode = .nearest
        
        super.init(texture: initialTexture, color: .clear, size: .zero)
        
        // Dynamically scales the asset on spawn
        applyTextureFittingConfiguredSize(initialTexture)
        yScale = config.initialFacing == .down ? -1 : 1
        
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
    
    /// Applies the texture and proportionally scales it down to fit the configured size width (64)
    /// This prevents high-res assets from becoming giants, while maintaining their natural aspect ratio.
    private func applyTextureAndSize(_ newTexture: SKTexture) {
        self.texture = newTexture
        let texSize = newTexture.size()
        
        guard texSize.width > 0 else { return }
        
        // Calculate the height based on the artwork's native aspect ratio
        let ratio = texSize.height / texSize.width
        self.size = CGSize(width: config.size.width, height: config.size.width * ratio)
    }

    /// Fits the complete artwork inside the configured size while preserving
    /// its aspect ratio across horizontal and vertical directions.
    private func applyTextureFittingConfiguredSize(_ newTexture: SKTexture) {
        texture = newTexture
        let textureSize = newTexture.size()

        guard textureSize.width > 0, textureSize.height > 0 else { return }

        let scale = min(
            config.size.width / textureSize.width,
            config.size.height / textureSize.height
        )
        size = CGSize(
            width: textureSize.width * scale,
            height: textureSize.height * scale
        )
    }

    private func updateAnimation(facing: MovementDirection, isWalking: Bool, forceUpdate: Bool = false) {
        let facingChanged = facing != currentFacing
        let walkStateChanged = isWalking != self.isWalking
        
        currentFacing = facing
        self.isWalking = isWalking

        guard facingChanged || walkStateChanged || forceUpdate else { return }
        removeAction(forKey: "walk")
        
        switch currentPhase {
        case .worm:
            let wormDirection = Self.textureDirectionUsingNorthForVertical(facing)
            yScale = facing == .down ? -1 : 1

            if isWalking {
                let tex0 = SKTexture(imageNamed: "Worm_\(wormDirection)_0")
                let tex1 = SKTexture(imageNamed: "Worm_\(wormDirection)_1")
                tex0.filteringMode = .nearest
                tex1.filteringMode = .nearest
                
                let walk = SKAction.animate(with: [tex0, tex1], timePerFrame: 0.2)
                run(.repeatForever(walk), withKey: "walk")
                
                applyTextureFittingConfiguredSize(tex0)
            } else {
                let idleTex = SKTexture(imageNamed: "Worm_\(wormDirection)_0")
                idleTex.filteringMode = .nearest
                applyTextureFittingConfiguredSize(idleTex)
            }
            
        case .pupa:
            // FIX: explicitly handle the Pupa phase so it doesn't freeze on a giant worm
            yScale = 1
            let cocoonTex = SKTexture(imageNamed: "Cocoon")
            cocoonTex.filteringMode = .nearest
            applyTextureAndSize(cocoonTex)
            
        case .butterfly:
            let butterflyDirection = Self.textureDirectionUsingNorthForVertical(facing)
            yScale = facing == .down ? -1 : 1

            if isWalking {
                let tex0 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_0")
                let tex1 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_1")
                let tex2 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_2")
                let tex3 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_3")
                [tex0, tex1, tex2, tex3].forEach { $0.filteringMode = .nearest }

                let flying = SKAction.animate(
                    with: [tex0, tex1, tex2, tex3, tex2, tex1],
                    timePerFrame: 0.12
                )
                run(.repeatForever(flying), withKey: "walk")

                applyTextureFittingConfiguredSize(tex0)
            } else {
                let tex0 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_0")
                let tex1 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_1")
                let tex2 = SKTexture(imageNamed: "Butterfly_\(butterflyDirection)_2")
                tex0.filteringMode = .nearest
                tex1.filteringMode = .nearest
                tex2.filteringMode = .nearest
                
                let idle = SKAction.animate(with: [tex0, tex1, tex2, tex1], timePerFrame: 0.2)
                run(.repeatForever(idle), withKey: "walk")
                
                applyTextureFittingConfiguredSize(tex0)
            }
        }
    }

    /// Vertical movement reuses the north artwork; callers flip it for south.
    private static func textureDirectionUsingNorthForVertical(
        _ facing: MovementDirection
    ) -> String {
        switch facing {
        case .up, .down:
            return "N"
        case .left, .right:
            return facing.compassCode
        }
    }
}
