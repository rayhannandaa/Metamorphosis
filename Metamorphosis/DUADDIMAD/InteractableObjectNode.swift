//
//  InteractableObjectNode.swift
//  Metamorphosis
//

import CoreGraphics
import SpriteKit

/// A SpriteKit node representing an interactable object rendered as a simple rectangle.
/// It provides visual feedback (flashing alpha and subtle shaking) when the character
/// is in proximity.
final class InteractableObjectNode: SKNode {
    let objectType: InteractableObjectType
    let baseSize: CGSize
    let basePosition: CGPoint
    let proximityRadius: CGFloat

    private(set) var isHighlighted: Bool = false

    private let visualNode: SKShapeNode
    private let labelNode: SKLabelNode

    private static let flashActionKey = "proximity_flash"
    private static let shakeActionKey = "proximity_shake"

    init(
        objectType: InteractableObjectType,
        position: CGPoint? = nil,
        size: CGSize? = nil,
        proximityRadius: CGFloat? = nil
    ) {
        self.objectType = objectType
        let effectiveSize = size ?? objectType.defaultSize
        let effectivePos = position ?? objectType.defaultPosition
        self.baseSize = effectiveSize
        self.basePosition = effectivePos
        self.proximityRadius = proximityRadius ?? (max(effectiveSize.width, effectiveSize.height) * 0.5 + 40.0)

        // Simple rectangle visual
        let rect = CGRect(
            x: -effectiveSize.width / 2,
            y: -effectiveSize.height / 2,
            width: effectiveSize.width,
            height: effectiveSize.height
        )
        visualNode = SKShapeNode(rect: rect, cornerRadius: 4)
        visualNode.fillColor = objectType.defaultColor
        visualNode.strokeColor = SKColor.white.withAlphaComponent(0.6)
        visualNode.lineWidth = 1.5

        // Label displaying object name
        labelNode = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        labelNode.text = objectType.displayName
        labelNode.fontSize = min(12, max(9, effectiveSize.height * 0.22))
        labelNode.fontColor = .white
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 1

        super.init()

        self.name = "Interactable_\(objectType.rawValue)"
        self.position = effectivePos
        self.zPosition = 2.4 // Above floor/room background

        addChild(visualNode)
        addChild(labelNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Proximity Check

    /// Computes distance from this object's center to a given point (e.g. player position).
    func distance(to point: CGPoint) -> CGFloat {
        let dx = position.x - point.x
        let dy = position.y - point.y
        return (dx * dx + dy * dy).squareRoot()
    }

    /// Determines if the given position is within interaction proximity.
    func isInProximity(of point: CGPoint) -> Bool {
        return distance(to: point) <= proximityRadius
    }

    // MARK: - Visual Feedback (Flashing & Subtle Shaking)

    /// Updates whether the object is highlighted due to character proximity.
    func setHighlighted(_ highlighted: Bool) {
        guard highlighted != isHighlighted else { return }
        isHighlighted = highlighted

        if highlighted {
            startFlashing()
            startSubtleShaking()
            visualNode.strokeColor = SKColor.yellow
            visualNode.lineWidth = 2.5
        } else {
            stopFlashing()
            stopSubtleShaking()
            visualNode.strokeColor = SKColor.white.withAlphaComponent(0.6)
            visualNode.lineWidth = 1.5
        }
    }

    private func startFlashing() {
        // Continuous flashing between dim alpha and bright alpha
        visualNode.removeAction(forKey: Self.flashActionKey)
        let fadeOut = SKAction.fadeAlpha(to: 0.45, duration: 0.22)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.22)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        visualNode.run(SKAction.repeatForever(sequence), withKey: Self.flashActionKey)
    }

    private func stopFlashing() {
        visualNode.removeAction(forKey: Self.flashActionKey)
        visualNode.alpha = 1.0
    }

    private func startSubtleShaking() {
        // Subtle micro-oscillations with a resting interval
        visualNode.removeAction(forKey: Self.shakeActionKey)
        let jiggle1 = SKAction.moveBy(x: -1.2, y: 0.6, duration: 0.04)
        let jiggle2 = SKAction.moveBy(x: 2.4, y: -1.2, duration: 0.04)
        let jiggle3 = SKAction.moveBy(x: -1.2, y: 0.6, duration: 0.04)
        let reset = SKAction.move(to: .zero, duration: 0.04)
        let pause = SKAction.wait(forDuration: 1.2)
        let shakeSeq = SKAction.sequence([jiggle1, jiggle2, jiggle3, reset, pause])
        visualNode.run(SKAction.repeatForever(shakeSeq), withKey: Self.shakeActionKey)
    }

    private func stopSubtleShaking() {
        visualNode.removeAction(forKey: Self.shakeActionKey)
        visualNode.position = .zero
    }

    // MARK: - Interaction

    /// Triggers monologue based on character state and time of day.
    func triggerMonologue(for phase: ASARYUNGamePhase, isDaytime: Bool) -> String? {
        return objectType.monologue(for: phase, isDaytime: isDaytime)
    }
}
