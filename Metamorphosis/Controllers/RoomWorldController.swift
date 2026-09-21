import SpriteKit

final class RoomWorldController {
    private unowned let scene: SKScene
    private let config: RoomConfig

    init(scene: SKScene, config: RoomConfig) {
        self.scene = scene
        self.config = config
    }

    func buildWorld() {
        for object in config.objects {
            addObject(object)
        }
    }

    private func addObject(_ object: RoomObjectConfig) {
        let node = SKSpriteNode(imageNamed: object.assetName)
        node.name = object.name
        node.size = object.size
        node.position = object.position
        node.zPosition = object.zPosition
        scene.addChild(node)
    }
}
