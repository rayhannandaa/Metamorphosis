import CoreGraphics

struct RoomObjectConfig {
    let name: String
    let assetName: String
    let size: CGSize
    let position: CGPoint
    let zPosition: CGFloat
    let rotation: CGFloat

    init(
        name: String,
        assetName: String,
        size: CGSize,
        position: CGPoint,
        zPosition: CGFloat,
        rotation: CGFloat = 0
    ) {
        self.name = name
        self.assetName = assetName
        self.size = size
        self.position = position
        self.zPosition = zPosition
        self.rotation = rotation
    }
}
