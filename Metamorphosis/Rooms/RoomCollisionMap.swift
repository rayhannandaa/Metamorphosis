import Foundation

extension RoomConfig {
    /// First-pass collision map. Every selected object uses the exact same
    /// center, size, and rotation as its room asset.
    var collisionObjects: [RoomCollisionConfig] {
        var collisions: [RoomCollisionConfig] = []

        for object in objects {
            switch object.name {
            case "TableL":
                collisions.append(contentsOf: tableLCollisions(for: object))
            case "Walls", "Sofa", "Wardrobe", "Table", "TableTwo", "Door":
                collisions.append(RoomCollisionConfig(object: object))
            default:
                if object.name.hasPrefix("Chair_") {
                    collisions.append(RoomCollisionConfig(object: object))
                }
            }
        }

        return collisions
    }

    /// TableL is visually an L rather than a filled 150 x 190 rectangle.
    /// These two bars match its opaque 30-point left side and 70-point base,
    /// leaving the upper-right area open for the player to walk through.
    private func tableLCollisions(for object: RoomObjectConfig) -> [RoomCollisionConfig] {
        let verticalSize = CGSize(width: 30, height: object.size.height)
        let baseSize = CGSize(width: object.size.width, height: 70)

        return [
            RoomCollisionConfig(
                name: "TableL_Vertical",
                position: transformedPosition(
                    localOffset: CGPoint(x: -60, y: 0),
                    for: object
                ),
                size: verticalSize,
                rotation: object.rotation
            ),
            RoomCollisionConfig(
                name: "TableL_Base",
                position: transformedPosition(
                    localOffset: CGPoint(x: 0, y: -60),
                    for: object
                ),
                size: baseSize,
                rotation: object.rotation
            )
        ]
    }

    private func transformedPosition(
        localOffset: CGPoint,
        for object: RoomObjectConfig
    ) -> CGPoint {
        let cosine = cos(object.rotation)
        let sine = sin(object.rotation)
        return CGPoint(
            x: object.position.x + localOffset.x * cosine - localOffset.y * sine,
            y: object.position.y + localOffset.x * sine + localOffset.y * cosine
        )
    }
}
