//
//  InteractableObjectNode.swift
//  Metamorphosis
//

import SpriteKit

/// Associates interaction behavior with an existing room sprite.
/// No additional placeholder node is rendered in the scene.
final class InteractableObjectNode {
    let objectType: InteractableObjectType
    let targetNode: SKSpriteNode
    let interactionMargin: CGFloat

    private(set) var isHighlighted: Bool = false
    private let markerNode: MarkerNode
    private let markerVerticalGap: CGFloat = 12
    private let markerZPosition: CGFloat = 20

    init(
        objectType: InteractableObjectType,
        targetNode: SKSpriteNode,
        interactionMargin: CGFloat
    ) {
        self.objectType = objectType
        self.targetNode = targetNode
        self.interactionMargin = interactionMargin
        self.markerNode = MarkerNode(objectType: objectType)

        markerNode.zPosition = markerZPosition
        updateMarkerPosition()
        targetNode.parent?.addChild(markerNode)
    }

    // MARK: - Proximity Check

    /// Computes the distance to the nearest edge of the real sprite. Converting
    /// into the sprite's local coordinates makes this work for rotated assets.
    func distance(to point: CGPoint) -> CGFloat {
        guard let parent = targetNode.parent else { return .infinity }

        let localPoint = targetNode.convert(point, from: parent)
        let bounds = CGRect(
            x: -targetNode.size.width * targetNode.anchorPoint.x,
            y: -targetNode.size.height * targetNode.anchorPoint.y,
            width: targetNode.size.width,
            height: targetNode.size.height
        )
        let nearestX = min(max(localPoint.x, bounds.minX), bounds.maxX)
        let nearestY = min(max(localPoint.y, bounds.minY), bounds.maxY)
        let dx = localPoint.x - nearestX
        let dy = localPoint.y - nearestY
        return (dx * dx + dy * dy).squareRoot()
    }

    /// Determines if the given position is within interaction proximity.
    func isInProximity(of point: CGPoint) -> Bool {
        distance(to: point) <= interactionMargin
    }

    // MARK: - Marker

    /// Shows the Room 0-style marker above the real asset.
    func setHighlighted(_ highlighted: Bool) {
        guard highlighted != isHighlighted else { return }
        isHighlighted = highlighted

        if highlighted {
            updateMarkerPosition()
            markerNode.show()
        } else {
            markerNode.hide()
        }
    }

    func removeMarker() {
        markerNode.removeFromParent()
    }

    private func updateMarkerPosition() {
        let targetFrame = targetNode.frame
        markerNode.position = CGPoint(
            x: targetFrame.midX,
            y: targetFrame.maxY + markerVerticalGap
        )
    }

    // MARK: - Interaction

    /// Triggers monologue based on character state and time of day.
    func triggerMonologue(for phase: GamePhase, isDaytime: Bool) -> String? {
        return objectType.monologue(for: phase, isDaytime: isDaytime)
    }
}
