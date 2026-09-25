//
//  GameSceneStore.swift
//  Metamorphosis
//
//  Owns the gameplay scene independently of SwiftUI view reconstruction.
//

import Combine
import CoreGraphics

@MainActor
final class GameSceneStore: ObservableObject {
    @Published private(set) var scene: RoomScene

    private var hasPreparedInitialScene = false

    init() {
        scene = Self.makeScene()
        configureDangerFeedback(for: scene)
        scene.setInitialContentVisible(false)
    }

    func prepareInitialScene() {
        guard !hasPreparedInitialScene else { return }
        hasPreparedInitialScene = true

        scene.session.revealInitialFood()
        scene.prepareForPresentation()
        scene.setInitialContentVisible(false)
    }

    func revealInitialContent() {
        scene.setInitialContentVisible(true)
    }

    @discardableResult
    func makeRestartScene() -> RoomScene {
        let newScene = Self.makeScene()
        configureDangerFeedback(for: newScene)
        newScene.prepareForPresentation()
        scene = newScene
        return newScene
    }

    private func configureDangerFeedback(for scene: RoomScene) {
        scene.session.onSurvivalWarningEntered = {
            GameHapticsManager.shared.playDangerWarning()
        }
    }

    private static func makeScene() -> RoomScene {
        RoomScene(config: .room, zoomScale: 600 / 437)
    }
}
