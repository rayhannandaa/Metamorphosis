import SpriteKit
import SwiftUI

struct GameView: View {
    @ObservedObject var sceneStore: GameSceneStore
    @ObservedObject var flowCoordinator: GameFlowCoordinator
    @State private var isIntroDismissing = false

    private var scene: RoomScene {
        sceneStore.scene
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "131313")

                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .id(ObjectIdentifier(scene))

                ZStack {
                    gameFlowTriggers

                    if flowCoordinator.state != .cocoonCutscene {
                        GameplayOverlay(
                            scene: scene,
                            isIntroBlockingHUD: flowCoordinator.state == .larvaDialogue
                                && !isIntroDismissing,
                            isStoryDialogBlockingControls: flowCoordinator.state.blocksGameplayControls
                        )
                        .id(ObjectIdentifier(scene))
                    }

                    sequenceOverlay

                    SurvivalOverlay(
                        session: scene.session,
                        onPlayAgain: playAgain
                    )
                    .id(ObjectIdentifier(scene.session))

                    VictoryOverlay(
                        session: scene.session,
                        onPlayAgain: playAgain
                    )
                    .id(ObjectIdentifier(scene.session))
                }
                .opacity(showsGameplayInterface ? 1 : 0)
                .allowsHitTesting(showsGameplayInterface)
            }
        }
        .ignoresSafeArea()
    }

    private var showsGameplayInterface: Bool {
        flowCoordinator.state != .loading
            && flowCoordinator.state != .openingIntro
    }

    private var gameFlowTriggers: some View {
        ZStack {
            DayTwoCutsceneTrigger(session: scene.session) {
                beginDayTwoCutscene()
            }

            EscapeRequestTrigger(session: scene.session) {
                flowCoordinator.transition(to: .escapeDialogue)
            }
        }
        .id(ObjectIdentifier(scene.session))
    }

    @ViewBuilder
    private var sequenceOverlay: some View {
        switch flowCoordinator.state {
        case .larvaDialogue:
            DialogSequenceOverlay(
                sequence: GameDialogCatalog.introduction,
                onDismissStarted: {
                    isIntroDismissing = true
                },
                onDismiss: {
                    isIntroDismissing = false
                    flowCoordinator.transition(to: .playing)
                    scene.session.start()
                }
            )

        case .cocoonCutscene:
            DayTwoCutsceneView {
                finishDayTwoCutscene()
            }
            .allowsHitTesting(true)

        case .butterflyDialogue:
            DialogSequenceOverlay(
                sequence: GameDialogCatalog.butterflyTransformation
            ) {
                flowCoordinator.transition(to: .playing)
                scene.session.start()
            }

        case .escapeDialogue:
            DialogSequenceOverlay(sequence: GameDialogCatalog.windowEscape) {
                beginWindowEscape()
            }

        case .loading, .openingIntro, .playing, .escaping:
            EmptyView()
        }
    }

    private func beginDayTwoCutscene() {
        scene.stopAllMovement()
        scene.session.pause()
        scene.setPlayerVisible(false)
        scene.showCocoonCutscene()
        flowCoordinator.transition(to: .cocoonCutscene)
    }

    private func finishDayTwoCutscene() {
        scene.session.skipToDay(3)
        scene.setPlayerVisible(true)
        scene.hideCocoonCutscene {
            flowCoordinator.transition(to: .butterflyDialogue)
        }
    }

    private func beginWindowEscape() {
        scene.session.beginWindowEscape()

        flowCoordinator.transition(to: .escaping)

        scene.performWindowEscape {
            scene.session.completeWindowEscape()
            flowCoordinator.transition(to: .playing)
        }
    }

    private func playAgain() {
        let newScene = sceneStore.makeRestartScene()

        isIntroDismissing = false
        flowCoordinator.transition(to: .playing)
        newScene.session.start()
    }
}

#Preview(
    traits: .fixedLayout(width: 402, height: 874),
    .portrait
) {
    GameView(
        sceneStore: GameSceneStore(),
        flowCoordinator: GameFlowCoordinator()
    )
}
