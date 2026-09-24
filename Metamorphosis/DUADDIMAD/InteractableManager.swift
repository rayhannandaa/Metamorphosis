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

    private(set) var interactableNodes: [InteractableObjectNode] = []
    private(set) var currentHighlightedNode: InteractableObjectNode?

    /// Attaches the manager to a scene, adding rectangular nodes for all 9 interactable objects.
    func setupObjects(in scene: SKScene) {
        // Clear any existing nodes
        for node in interactableNodes {
            node.removeFromParent()
        }
        interactableNodes.removeAll()

        for type in InteractableObjectType.allCases {
            let node = InteractableObjectNode(objectType: type)
            scene.addChild(node)
            interactableNodes.append(node)
        }
    }

    /// Call each frame with the player's current position to update proximity highlights.
    func update(playerPosition: CGPoint) {
        var closestNode: InteractableObjectNode? = nil
        var minDistance: CGFloat = .infinity

        for node in interactableNodes {
            let dist = node.distance(to: playerPosition)
            if dist <= node.proximityRadius && dist < minDistance {
                minDistance = dist
                closestNode = node
            }
        }

        if closestNode !== currentHighlightedNode {
            currentHighlightedNode?.setHighlighted(false)
            currentHighlightedNode = closestNode
            closestNode?.setHighlighted(true)

            let newName = closestNode?.objectType.displayName
            if nearbyObjectName != newName {
                nearbyObjectName = newName
            }
        }
    }

    /// Interacts with the currently highlighted object (if within proximity).
    /// Returns the monologue text if available.
    @discardableResult
    func triggerInteraction(phase: ASARYUNGamePhase, isDaytime: Bool) -> String? {
        guard let node = currentHighlightedNode else { return nil }
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
}
