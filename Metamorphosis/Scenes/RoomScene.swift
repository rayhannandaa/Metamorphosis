import SpriteKit
import SwiftUI

final class RoomScene: SKScene {
    private let config: RoomConfig
    private let playerConfig: PlayerConfig
    private let zoomScale: CGFloat
    private let initialCameraPosition: CGPoint
    private let cameraNode = SKCameraNode()
    private var hasBuiltWorld = false
    private var lastUpdateTime: TimeInterval?

    private lazy var worldController = RoomWorldController(
        scene: self,
        config: config
    )
    
    private lazy var playerNode = PlayerNode(
        config: playerConfig
    )
    
    private lazy var movementController = PlayerMovementController(
        player: playerNode,
        config: playerConfig,
        bounds: CGRect(origin: .zero, size: config.sceneSize)
    )

    init(
        config: RoomConfig,
        playerConfig: PlayerConfig = .centaur,
        zoomScale: CGFloat = 1,
        initialCameraPosition: CGPoint? = nil
    ) {
        self.config = config
        self.playerConfig = playerConfig
        self.zoomScale = zoomScale
        self.initialCameraPosition = initialCameraPosition ?? config.initialCameraPosition
        super.init(size: config.sceneSize)
        scaleMode = .aspectFill
        backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        buildWorldIfNeeded()
        setupCameraIfNeeded(in: view)
    }

    private func buildWorldIfNeeded() {
        guard !hasBuiltWorld else { return }
        hasBuiltWorld = true
        worldController.buildWorld()
        addChild(playerNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdateTime = currentTime }
        guard let lastUpdateTime else { return }
        movementController.update(deltaTime: currentTime - lastUpdateTime)
        
        if let view = self.view {
            cameraNode.position = clampedCameraPosition(
                for: playerNode.position,
                in: view
            )
        }
    }
    
    func setMovementDirection(_ direction: MovementDirection, isActive: Bool) {
        movementController.setDirection(direction, isActive: isActive)
    }

    private func setupCameraIfNeeded(in view: SKView) {
        guard cameraNode.parent == nil else { return }

        cameraNode.setScale(1 / zoomScale)
        cameraNode.position = clampedCameraPosition(
            for: initialCameraPosition,
            in: view
        )
        addChild(cameraNode)
        camera = cameraNode
    }

    private func clampedCameraPosition(
        for target: CGPoint,
        in view: SKView
    ) -> CGPoint {
        let baseScale = max(
            view.bounds.width / config.sceneSize.width,
            view.bounds.height / config.sceneSize.height
        )
        let effectiveScale = baseScale * zoomScale
        let visibleSize = CGSize(
            width: view.bounds.width / effectiveScale,
            height: view.bounds.height / effectiveScale
        )

        return CGPoint(
            x: clampedCameraAxis(
                target.x,
                visibleLength: visibleSize.width,
                worldLength: config.sceneSize.width
            ),
            y: clampedCameraAxis(
                target.y,
                visibleLength: visibleSize.height,
                worldLength: config.sceneSize.height
            )
        )
    }

    private func clampedCameraAxis(
        _ value: CGFloat,
        visibleLength: CGFloat,
        worldLength: CGFloat
    ) -> CGFloat {
        guard visibleLength < worldLength else {
            return worldLength / 2
        }

        let halfVisibleLength = visibleLength / 2
        return min(
            max(value, halfVisibleLength),
            worldLength - halfVisibleLength
        )
    }
}

private struct RoomScenePreview: View {
    private let scene: RoomScene

    init() {
        let scene = RoomScene(
            config: .room,
            initialCameraPosition: CGPoint(x: 250, y: 400)
        )
        scene.scaleMode = .aspectFit
        self.scene = scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .background(Color.black)
    }
}

#Preview(
    traits: .fixedLayout(width: 500, height: 800)
) {
    RoomScenePreview()
}
