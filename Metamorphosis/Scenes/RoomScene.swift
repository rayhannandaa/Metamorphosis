import SpriteKit
import SwiftUI

final class RoomScene: SKScene {
    private let config: RoomConfig
    private let cameraNode = SKCameraNode()
    private var hasBuiltWorld = false

    private lazy var worldController = RoomWorldController(
        scene: self,
        config: config
    )

    init(config: RoomConfig) {
        self.config = config
        super.init(size: config.sceneSize)
        scaleMode = .aspectFill
        backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        buildWorldIfNeeded()
        setupCameraIfNeeded()
    }

    private func buildWorldIfNeeded() {
        guard !hasBuiltWorld else { return }
        hasBuiltWorld = true
        worldController.buildWorld()
    }

    private func setupCameraIfNeeded() {
        guard cameraNode.parent == nil else { return }

        cameraNode.position = CGPoint(
            x: config.sceneSize.width / 2,
            y: config.sceneSize.height / 2
        )
        addChild(cameraNode)
        camera = cameraNode
    }
}

private struct RoomScenePreview: View {
    private let scene: RoomScene

    init() {
        let scene = RoomScene(config: .room)
        scene.scaleMode = .aspectFit
        self.scene = scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .background(Color.black)
    }
}

#Preview(
    traits: .fixedLayout(width: 250, height: 400)
) {
    RoomScenePreview()
}
