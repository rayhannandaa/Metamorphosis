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

        let initialTexture = SKTexture(imageNamed: "Worm_\(config.initialFacing.compassCode)_0")
        initialTexture.filteringMode = .nearest
        
        super.init(texture: initialTexture, color: .clear, size: .zero)
        
        // Dynamically scales the asset on spawn
        applyTextureAndSize(initialTexture)
        
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

    private func updateAnimation(facing: MovementDirection, isWalking: Bool, forceUpdate: Bool = false) {
        let facingChanged = facing != currentFacing
        let walkStateChanged = isWalking != self.isWalking
        
        currentFacing = facing
        self.isWalking = isWalking

        guard facingChanged || walkStateChanged || forceUpdate else { return }
        removeAction(forKey: "walk")
        
        // Swaps N and S logic to match your inverted sprite assets
        var direction = facing.compassCode
        if direction == "S" { direction = "N" }
        else if direction == "N" { direction = "S" }

        switch currentPhase {
        case .worm:
            if isWalking {
                let tex0 = SKTexture(imageNamed: "Worm_\(direction)_0")
                let tex1 = SKTexture(imageNamed: "Worm_\(direction)_1")
                tex0.filteringMode = .nearest
                tex1.filteringMode = .nearest
                
                let walk = SKAction.animate(with: [tex0, tex1], timePerFrame: 0.2)
                run(.repeatForever(walk), withKey: "walk")
                
                applyTextureAndSize(tex0)
            } else {
                let idleTex = SKTexture(imageNamed: "Worm_\(direction)_0")
                idleTex.filteringMode = .nearest
                applyTextureAndSize(idleTex)
            }
            
        case .pupa:
            // FIX: explicitly handle the Pupa phase so it doesn't freeze on a giant worm
            let cocoonTex = SKTexture(imageNamed: "Cocoon")
            cocoonTex.filteringMode = .nearest
            applyTextureAndSize(cocoonTex)
            
        case .butterfly:
            if isWalking {
                let walkTex = SKTexture(imageNamed: "Butterfly_\(direction)_3")
                walkTex.filteringMode = .nearest
                applyTextureAndSize(walkTex)
            } else {
                let tex0 = SKTexture(imageNamed: "Butterfly_\(direction)_0")
                let tex1 = SKTexture(imageNamed: "Butterfly_\(direction)_1")
                let tex2 = SKTexture(imageNamed: "Butterfly_\(direction)_2")
                tex0.filteringMode = .nearest
                tex1.filteringMode = .nearest
                tex2.filteringMode = .nearest
                
                let idle = SKAction.animate(with: [tex0, tex1, tex2, tex1], timePerFrame: 0.2)
                run(.repeatForever(idle), withKey: "walk")
                
                applyTextureAndSize(tex0)
            }
        }
    }
}
