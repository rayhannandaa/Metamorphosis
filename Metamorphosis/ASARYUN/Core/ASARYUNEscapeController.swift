//
//  ASARYUNEscapeController.swift
//  Metamorphosis
//
//  Runs the butterfly's scripted flight through the window. This movement
//  intentionally bypasses normal room collision without opening the wall.
//

import SpriteKit

final class ASARYUNEscapeController {
    private unowned let player: PlayerNode
    private let windowPosition: CGPoint

    init(player: PlayerNode, windowPosition: CGPoint) {
        self.player = player
        self.windowPosition = windowPosition
    }

    func perform(completion: @escaping () -> Void) {
        player.beginScriptedFlight(facing: .up)
        player.zPosition = 30

        let approachPoint = CGPoint(
            x: windowPosition.x,
            y: windowPosition.y - 62
        )
        let outsidePoint = CGPoint(
            x: windowPosition.x,
            y: windowPosition.y + 34
        )

        let approach = SKAction.move(
            to: approachPoint,
            duration: 0.8
        )
        approach.timingMode = .easeInEaseOut

        let passThroughWindow = SKAction.group([
            SKAction.move(to: outsidePoint, duration: 1.05),
            SKAction.scale(to: 0.28, duration: 1.05),
            SKAction.fadeOut(withDuration: 1.05)
        ])
        passThroughWindow.timingMode = .easeIn

        player.run(
            .sequence([
                approach,
                .wait(forDuration: 0.12),
                passThroughWindow,
                .run(completion)
            ]),
            withKey: "windowEscape"
        )
    }
}
