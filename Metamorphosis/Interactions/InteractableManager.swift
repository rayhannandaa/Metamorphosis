//
//  InteractableManager.swift
//  Metamorphosis
//

import CoreGraphics
import SpriteKit
import Combine

/// Coordinates all interactable objects in a scene: proximity tracking,
/// highlight state updates, and triggering monologues.
final class InteractableManager: ObservableObject {
    @Published private(set) var activeMonologue: (objectName: String, text: String)? = nil
    @Published private(set) var nearbyObjectName: String? = nil
    var onButterflyWindowInteraction: (() -> Void)?

    private(set) var interactableNodes: [InteractableObjectNode] = []
    private(set) var currentHighlightedNode: InteractableObjectNode?

    /// Associates each interaction type with its existing room sprite.
    func setupObjects(in scene: SKScene) {
        for node in interactableNodes {
            node.removeMarker()
        }
        interactableNodes.removeAll()
        currentHighlightedNode = nil
        nearbyObjectName = nil

        for type in InteractableObjectType.allCases {
            guard let targetNode = scene.childNode(withName: "//\(type.roomNodeName)") as? SKSpriteNode else {
                continue
            }
            let interactableNode = InteractableObjectNode(
                objectType: type,
                targetNode: targetNode,
                interactionMargin: type.interactionMargin
            )
            interactableNodes.append(interactableNode)
        }
    }

    /// Call each frame with the player's current position to update proximity highlights.
    func update(playerPosition: CGPoint) {
        var closestNode: InteractableObjectNode? = nil
        var minDistance: CGFloat = .infinity

        for node in interactableNodes {
            let dist = node.distance(to: playerPosition)
            let isNearby = node.isInProximity(of: playerPosition)
            node.setHighlighted(isNearby)

            if isNearby && dist < minDistance {
                minDistance = dist
                closestNode = node
            }
        }

        if closestNode !== currentHighlightedNode {
            currentHighlightedNode = closestNode

            let newName = closestNode?.objectType.displayName
            if nearbyObjectName != newName {
                nearbyObjectName = newName
            }
        }
    }

    /// Interacts with the currently highlighted object (if within proximity).
    /// Returns the monologue text if available.
    @discardableResult
    func triggerInteraction(phase: GamePhase, isDaytime: Bool) -> String? {
        guard let node = currentHighlightedNode else { return nil }
        return triggerInteraction(with: node, phase: phase, isDaytime: isDaytime)
    }

    /// Uses the same scene-level marker hit testing as Room 0.
    @discardableResult
    func triggerInteraction(
        at location: CGPoint,
        in scene: SKScene,
        phase: GamePhase,
        isDaytime: Bool
    ) -> String? {
        for sceneNode in scene.nodes(at: location) {
            guard let marker = sceneNode as? MarkerNode,
                  marker.isRevealed,
                  let interactableNode = interactableNodes.first(where: {
                      $0.objectType == marker.objectType
                  })
            else {
                continue
            }

            return triggerInteraction(
                with: interactableNode,
                phase: phase,
                isDaytime: isDaytime
            )
        }

        return nil
    }

    private func triggerInteraction(
        with node: InteractableObjectNode,
        phase: GamePhase,
        isDaytime: Bool
    ) -> String? {
        if node.objectType == .window, phase == .butterfly {
            onButterflyWindowInteraction?()
            return nil
        }

        guard let monologue = node.triggerMonologue(for: phase, isDaytime: isDaytime) else {
            return nil
        }

        activeMonologue = (objectName: node.objectType.displayName, text: monologue)
        return monologue
    }

    /// Dismisses the currently displayed monologue.
    func dismissMonologue() {
        activeMonologue = nil
    }

    func clearCurrentInteraction() {
        currentHighlightedNode?.setHighlighted(false)
        currentHighlightedNode = nil
        nearbyObjectName = nil
    }

    /// Returns the real room sprite's center for the development test harness.
    func position(for type: InteractableObjectType) -> CGPoint? {
        interactableNodes.first { $0.objectType == type }?.targetNode.position
    }
}
