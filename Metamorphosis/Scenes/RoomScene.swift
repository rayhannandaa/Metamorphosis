import SpriteKit
import SwiftUI

final class RoomScene: SKScene {
    let interactableManager: InteractableManager
    let session: GameSessionController

    private let config: RoomConfig
    private let playerConfig: PlayerConfig
    private let zoomScale: CGFloat
    private let initialCameraPosition: CGPoint
    private let cameraNode = SKCameraNode()
    private var hasBuiltWorld = false
    private var lastUpdateTime: TimeInterval?
    private var isEscaping = false
    private var escapeController: EscapeController?

    private lazy var worldController = RoomWorldController(
        scene: self,
        config: config
    )
    
    private lazy var playerNode = PlayerNode(
        config: playerConfig
    )

    private lazy var collisionController = RoomCollisionController(
        obstacles: config.collisionObjects,
        boundary: config.roomBoundary,
        playerSpriteSize: playerConfig.size
    )
    
    private lazy var movementController = PlayerMovementController(
        player: playerNode,
        config: playerConfig,
        bounds: CGRect(origin: .zero, size: config.sceneSize),
        collisionController: collisionController
    )
    init(
        config: RoomConfig,
        playerConfig: PlayerConfig = .player,
        zoomScale: CGFloat = 1,
        initialCameraPosition: CGPoint? = nil,
        dependencies: RoomSceneDependencies = .live()
    ) {
        self.config = config
        self.playerConfig = playerConfig
        self.zoomScale = zoomScale
        self.initialCameraPosition = initialCameraPosition ?? config.initialCameraPosition
        self.interactableManager = dependencies.interactableManager
        self.session = dependencies.session
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
        
        interactableManager.setupObjects(in: self)
        interactableManager.onButterflyWindowInteraction = { [weak self] in
            self?.session.requestWindowEscape()
            self?.interactableManager.clearCurrentInteraction()
        }
        
        if let window = config.objects.first(where: { $0.name == "Window" }) {
                escapeController = EscapeController(
                    player: playerNode,
                    windowPosition: window.position
                )
                let collisionController = self.collisionController
                session.attach(
                    scene: self,
                    playerNode: playerNode,
                    windowPosition: window.position,
                    windowSize: window.size,
                    sceneSize: config.sceneSize,
                    isFoodPlacementValid: { position, size in
                        collisionController.isAreaClear(
                            center: position,
                            size: size,
                            clearance: GameConfig.foodSpawnClearance
                        )
                    }
                )
            }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if session.isEscapeRequested || isEscaping || session.isVictory {
            interactableManager.clearCurrentInteraction()
        } else {
            interactableManager.update(
                playerPosition: collisionController.interactionPosition(
                    for: playerNode.position
                )
            )
        }
        
        defer { lastUpdateTime = currentTime }
        guard let lastUpdateTime else { return }
        let deltaTime = currentTime - lastUpdateTime
        if isEscaping {
            // Scripted window flight owns the player animation and motion.
        } else if session.phase == .pupa
            || session.isGameOver
            || session.isEscapeRequested
            || session.isVictory {
            movementController.stop()
        } else {
            movementController.update(deltaTime: deltaTime)
        }
        session.update(deltaTime: deltaTime)
        
        if let view = self.view {
            cameraNode.position = clampedCameraPosition(
                for: playerNode.position,
                in: view
            )
        }
    }
    
    func setMovementDirection(_ direction: MovementDirection, isActive: Bool) {
        // The worm crawls and the butterfly flies; only the pupa is immobile.
        guard !session.isGameOver,
              !session.isEscapeRequested,
              !isEscaping,
              !session.isVictory
        else { return }
        guard session.phase != .pupa || !isActive else { return }
        movementController.setDirection(direction, isActive: isActive)
    }

    func advanceWormStepFrame(_ direction: MovementDirection) {
        guard !session.isGameOver,
              !session.isEscapeRequested,
              !isEscaping,
              !session.isVictory
        else { return }
        playerNode.advanceWormStepFrame(facing: direction)
    }

    func stopAllMovement() {
        movementController.stop()
    }

    func performWindowEscape(completion: @escaping () -> Void) {
        guard session.phase == .butterfly,
              !isEscaping,
              let escapeController
        else { return }

        isEscaping = true
        movementController.stop()
        interactableManager.clearCurrentInteraction()
        escapeController.perform(completion: completion)
    }

    func setPlayerVisible(_ isVisible: Bool) {
        playerNode.isHidden = !isVisible
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        interactableManager.triggerInteraction(
            at: location,
            in: self,
            phase: session.phase,
            isDaytime: session.isDaytime
        )
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
