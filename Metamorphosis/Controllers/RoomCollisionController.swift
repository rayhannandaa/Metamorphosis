import CoreGraphics

/// Resolves direct, position-based player movement against room furniture.
/// X and Y are checked separately so the player can slide along an obstacle.
final class RoomCollisionController {
    private let obstacles: [RoomCollisionConfig]
    private let boundary: RoomBoundary
    private let playerColliderSize: CGSize
    private let playerColliderOffset: CGPoint

    init(
        obstacles: [RoomCollisionConfig],
        boundary: RoomBoundary,
        playerSpriteSize: CGSize
    ) {
        self.obstacles = obstacles
        self.boundary = boundary

        // Only the player's feet block against furniture in this top-down
        // view. The room furniture itself still uses its exact asset size.
        playerColliderSize = CGSize(width: 24, height: 18)
        playerColliderOffset = CGPoint(
            x: 0,
            y: -(playerSpriteSize.height - playerColliderSize.height) / 2
        )
    }

    func resolvedTranslation(
        _ requested: CGVector,
        from playerPosition: CGPoint
    ) -> CGVector {
        var resolved = CGVector.zero
        var position = playerPosition

        if requested.dx != 0 {
            let proposed = CGPoint(x: position.x + requested.dx, y: position.y)
            if canOccupy(proposed, movingFrom: position) {
                position = proposed
                resolved.dx = requested.dx
            }
        }

        if requested.dy != 0 {
            let proposed = CGPoint(x: position.x, y: position.y + requested.dy)
            if canOccupy(proposed, movingFrom: position) {
                resolved.dy = requested.dy
            }
        }

        return resolved
    }

    /// The shared player point used for both furniture collision and
    /// interactable proximity checks.
    func interactionPosition(for playerPosition: CGPoint) -> CGPoint {
        CGPoint(
            x: playerPosition.x + playerColliderOffset.x,
            y: playerPosition.y + playerColliderOffset.y
        )
    }

    /// Returns whether an axis-aligned item can occupy a room position
    /// without touching WallsSide or any configured blocking object.
    func isAreaClear(
        center: CGPoint,
        size: CGSize,
        clearance: CGFloat = 0
    ) -> Bool {
        let paddedArea = OrientedRectangle(
            center: center,
            size: CGSize(
                width: size.width + clearance * 2,
                height: size.height + clearance * 2
            ),
            rotation: 0
        )

        guard isInsideBoundary(paddedArea) else { return false }
        return !obstacles.contains { intersects(paddedArea, $0) }
    }

    private func canOccupy(
        _ proposedPosition: CGPoint,
        movingFrom currentPosition: CGPoint
    ) -> Bool {
        let proposedCollider = playerCollider(at: proposedPosition)
        let currentCollider = playerCollider(at: currentPosition)

        guard isInsideBoundary(proposedCollider) else {
            return false
        }

        for obstacle in obstacles where intersects(proposedCollider, obstacle) {
            // If a spawn point or later map adjustment overlaps an object,
            // allow movement that takes the feet farther away so the player
            // can leave it, while still preventing re-entry.
            if intersects(currentCollider, obstacle),
               squaredDistance(from: proposedCollider.center, to: obstacle.position)
                > squaredDistance(from: currentCollider.center, to: obstacle.position) {
                continue
            }

            return false
        }

        return true
    }

    private func isInsideBoundary(_ collider: OrientedRectangle) -> Bool {
        collider.vertices.allSatisfy { vertex in
            vertex.x >= boundary.frame.minX
                && vertex.x <= boundary.frame.maxX
                && vertex.y >= boundary.frame.minY
                && vertex.y <= boundary.frame.maxY
        }
    }

    private func playerCollider(at playerPosition: CGPoint) -> OrientedRectangle {
        OrientedRectangle(
            center: interactionPosition(for: playerPosition),
            size: playerColliderSize,
            rotation: 0
        )
    }

    private func intersects(
        _ player: OrientedRectangle,
        _ obstacle: RoomCollisionConfig
    ) -> Bool {
        intersects(
            player,
            OrientedRectangle(
                center: obstacle.position,
                size: obstacle.size,
                rotation: obstacle.rotation
            )
        )
    }

    /// Separating Axis Theorem for two rectangles. This keeps a rotated
    /// object's collider aligned with the asset rather than using a larger
    /// axis-aligned bounding box.
    private func intersects(
        _ first: OrientedRectangle,
        _ second: OrientedRectangle
    ) -> Bool {
        let axes = first.axes + second.axes

        for axis in axes {
            let firstProjection = projection(of: first.vertices, onto: axis)
            let secondProjection = projection(of: second.vertices, onto: axis)

            // Touching edges are allowed; only actual overlap blocks movement.
            if firstProjection.max <= secondProjection.min
                || secondProjection.max <= firstProjection.min {
                return false
            }
        }

        return true
    }

    private func projection(
        of vertices: [CGPoint],
        onto axis: CGVector
    ) -> (min: CGFloat, max: CGFloat) {
        let values = vertices.map { $0.x * axis.dx + $0.y * axis.dy }
        return (values.min() ?? 0, values.max() ?? 0)
    }

    private func squaredDistance(from first: CGPoint, to second: CGPoint) -> CGFloat {
        let dx = first.x - second.x
        let dy = first.y - second.y
        return dx * dx + dy * dy
    }
}

private struct OrientedRectangle {
    let center: CGPoint
    let size: CGSize
    let rotation: CGFloat

    var axes: [CGVector] {
        let cosine = cos(rotation)
        let sine = sin(rotation)
        return [
            CGVector(dx: cosine, dy: sine),
            CGVector(dx: -sine, dy: cosine)
        ]
    }

    var vertices: [CGPoint] {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let xAxis = axes[0]
        let yAxis = axes[1]

        return [
            vertex(x: -halfWidth, y: -halfHeight, xAxis: xAxis, yAxis: yAxis),
            vertex(x: halfWidth, y: -halfHeight, xAxis: xAxis, yAxis: yAxis),
            vertex(x: halfWidth, y: halfHeight, xAxis: xAxis, yAxis: yAxis),
            vertex(x: -halfWidth, y: halfHeight, xAxis: xAxis, yAxis: yAxis)
        ]
    }

    private func vertex(
        x: CGFloat,
        y: CGFloat,
        xAxis: CGVector,
        yAxis: CGVector
    ) -> CGPoint {
        CGPoint(
            x: center.x + x * xAxis.dx + y * yAxis.dx,
            y: center.y + x * xAxis.dy + y * yAxis.dy
        )
    }
}
