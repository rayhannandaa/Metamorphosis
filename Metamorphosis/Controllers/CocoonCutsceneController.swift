//
//  CocoonCutsceneController.swift
//  Metamorphosis
//
//  SpriteKit owns the animated cutscene visual. SwiftUI only presents text.
//

import SpriteKit

final class CocoonCutsceneController {
    private weak var cameraNode: SKCameraNode?
    private let overlaySize: CGSize
    private var container: SKNode?

    init(cameraNode: SKCameraNode, overlaySize: CGSize) {
        self.cameraNode = cameraNode
        self.overlaySize = overlaySize
    }

    func show() {
        guard container == nil, let cameraNode else { return }

        let container = SKNode()
        container.name = "CocoonCutscene"
        container.zPosition = 10_000
        container.alpha = 0

        let backdrop = SKSpriteNode(
            color: .black,
            size: CGSize(
                width: overlaySize.width + 8,
                height: overlaySize.height + 8
            )
        )
        backdrop.zPosition = 0
        container.addChild(backdrop)

        let texture = SKTexture(imageNamed: "Cocoon")
        texture.filteringMode = .linear
        let textureSize = texture.size()
        let aspectRatio = textureSize.height / max(textureSize.width, 1)

        let cocoon = SKSpriteNode(texture: texture)
        cocoon.name = "CocoonCutsceneImage"
        cocoon.size = CGSize(
            width: overlaySize.width,
            height: overlaySize.width * aspectRatio
        )
        cocoon.zPosition = 1
        container.addChild(cocoon)

        let shake = SKAction.sequence([
            .moveTo(x: -3, duration: 0.12),
            .moveTo(x: 3, duration: 0.12)
        ])
        shake.timingMode = .easeInEaseOut
        cocoon.run(.repeatForever(shake), withKey: "CocoonShake")

        cameraNode.addChild(container)
        container.run(.fadeIn(withDuration: 0.8))
        self.container = container
    }

    func hide(completion: @escaping () -> Void) {
        guard let container else {
            completion()
            return
        }

        container.run(
            .sequence([
                .fadeOut(withDuration: 1.2),
                .removeFromParent(),
                .run { completion() }
            ])
        )
        self.container = nil
    }
}
