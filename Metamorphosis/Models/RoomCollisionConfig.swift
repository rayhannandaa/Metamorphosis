import CoreGraphics

/// A blocking rectangle in room coordinates. It intentionally lives apart
/// from the visual object configuration so collision can be tuned later
/// without resizing or moving the artwork.
struct RoomCollisionConfig {
    let name: String
    let position: CGPoint
    let size: CGSize
    let rotation: CGFloat

    init(
        name: String,
        position: CGPoint,
        size: CGSize,
        rotation: CGFloat = 0
    ) {
        self.name = name
        self.position = position
        self.size = size
        self.rotation = rotation
    }

    init(object: RoomObjectConfig) {
        self.init(
            name: object.name,
            position: object.position,
            size: object.size,
            rotation: object.rotation
        )
    }
}
