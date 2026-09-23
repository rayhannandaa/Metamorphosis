//
//  PlayerMovementController.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 22/09/26.
//


// Controllers/PlayerMovementController.swift
//import CoreGraphics
//import Foundation
import SpriteKit

final class PlayerMovementController {
    private let player: PlayerNode
    private let config: PlayerConfig
    private let bounds: CGRect
    private var activeDirections: Set<MovementDirection> = []

    init(player: PlayerNode, config: PlayerConfig, bounds: CGRect) {
        self.player = player
        self.config = config
        self.bounds = bounds
    }

    func setDirection(_ direction: MovementDirection, isActive: Bool) {
        if isActive {
            activeDirections.insert(direction)
        } else {
            activeDirections.remove(direction)
        }
    }

    func update(deltaTime: TimeInterval) {
        guard let facing = dominantDirection() else {
            player.stopWalking()
            return
        }

        let translation = translationVector(deltaTime: deltaTime)
        guard translation.dx != 0 || translation.dy != 0 else {
            player.stopWalking()
            return
        }

        player.move(by: translation, facing: facing)
        clampPlayerToBounds()
    }

    /// The art only has 4 facings, so diagonal input collapses onto one axis
    /// for animation purposes — movement itself still stays diagonal.
    private func dominantDirection() -> MovementDirection? {
        if activeDirections.contains(.up) { return .up }
        if activeDirections.contains(.down) { return .down }
        if activeDirections.contains(.left) { return .left }
        if activeDirections.contains(.right) { return .right }
        return nil
    }

    private func translationVector(deltaTime: TimeInterval) -> CGVector {
        var dx: CGFloat = 0
        var dy: CGFloat = 0

        if activeDirections.contains(.left) { dx -= 1 }
        if activeDirections.contains(.right) { dx += 1 }
        if activeDirections.contains(.up) { dy += 1 }
        if activeDirections.contains(.down) { dy -= 1 }

        guard dx != 0 || dy != 0 else { return .zero }

        let length = (dx * dx + dy * dy).squareRoot()
        let distance = config.speed * CGFloat(deltaTime)
        return CGVector(dx: dx / length * distance, dy: dy / length * distance)
    }

    private func clampPlayerToBounds() {
        let halfWidth = player.size.width / 2
        let halfHeight = player.size.height / 2
        player.position.x = min(max(player.position.x, bounds.minX + halfWidth), bounds.maxX - halfWidth)
        player.position.y = min(max(player.position.y, bounds.minY + halfHeight), bounds.maxY - halfHeight)
    }
}
