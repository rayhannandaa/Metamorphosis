import CoreGraphics

/// The walkable interior enclosed by WallsSide. Like Room 0's custom wall
/// path, this describes the open area instead of treating the transparent
/// wall artwork as one filled collision rectangle.
struct RoomBoundary {
    let frame: CGRect
}

extension RoomConfig {
    /// WallsSide surrounds the Floor, so deriving the boundary from Floor
    /// keeps it correct if the room artwork is repositioned or resized later.
    var roomBoundary: RoomBoundary {
        guard let floor = objects.first(where: { $0.name == "Floor" }) else {
            return RoomBoundary(frame: CGRect(origin: .zero, size: sceneSize))
        }

        return RoomBoundary(
            frame: CGRect(
                x: floor.position.x - floor.size.width / 2,
                y: floor.position.y - floor.size.height / 2,
                width: floor.size.width,
                height: floor.size.height
            )
        )
    }
}
