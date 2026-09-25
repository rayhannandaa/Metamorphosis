import SpriteKit
import SwiftUI

struct GameView: View {
    private static let roomConfig = RoomConfig.room

    @State private var scene: RoomScene
    @State private var sequenceState: GameSequenceState = .introduction
    @State private var isIntroDismissing = false
    @State private var cutsceneOpacity = 0.0

    init() {
        _scene = State(initialValue: Self.makeScene())
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "131313")

                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .id(ObjectIdentifier(scene))

                gameFlowTriggers

                if sequenceState != .cocoonCutscene {
                    GameplayOverlay(
                        scene: scene,
                        isIntroBlockingHUD: sequenceState == .introduction
                            && !isIntroDismissing,
                        isStoryDialogBlockingControls: sequenceState.blocksGameplayControls
                    )
                    .id(ObjectIdentifier(scene))
                }

                sequenceOverlay

                Color(red: 1.0, green: 0.91, blue: 0.65)
                    .opacity(sequenceState == .escaping ? 0.72 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

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
        }
        .ignoresSafeArea()
    }

    private var gameFlowTriggers: some View {
        ZStack {
            DayTwoCutsceneTrigger(session: scene.session) {
                beginDayTwoCutscene()
            }

            EscapeRequestTrigger(session: scene.session) {
                sequenceState = .escapeDialogue
            }
        }
        .id(ObjectIdentifier(scene.session))
    }

    @ViewBuilder
    private var sequenceOverlay: some View {
        switch sequenceState {
        case .introduction:
            DialogSequenceOverlay(
                sequence: GameDialogCatalog.introduction,
                onDismissStarted: {
                    isIntroDismissing = true
                },
                onDismiss: {
                    isIntroDismissing = false
                    sequenceState = .playing
                    scene.session.start()
                }
            )

        case .cocoonCutscene:
            DayTwoCutsceneView {
                finishDayTwoCutscene()
            }
            .opacity(cutsceneOpacity)
            .allowsHitTesting(true)

        case .butterflyDialogue:
            DialogSequenceOverlay(
                sequence: GameDialogCatalog.butterflyTransformation
            ) {
                sequenceState = .playing
                scene.session.start()
            }

        case .escapeDialogue:
            DialogSequenceOverlay(sequence: GameDialogCatalog.windowEscape) {
                beginWindowEscape()
            }

        case .playing, .escaping:
            EmptyView()
        }
    }

    private func beginDayTwoCutscene() {
        scene.stopAllMovement()
        scene.session.pause()
        scene.setPlayerVisible(false)
        sequenceState = .cocoonCutscene

        withAnimation(.easeInOut(duration: 2.0)) {
            cutsceneOpacity = 1.0
        }
    }

    private func finishDayTwoCutscene() {
        scene.session.skipToDay(3)
        scene.setPlayerVisible(true)

        withAnimation(.easeInOut(duration: 2.5)) {
            cutsceneOpacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            sequenceState = .butterflyDialogue
        }
    }

    private func beginWindowEscape() {
        scene.session.beginWindowEscape()

        withAnimation(.easeIn(duration: 1.6)) {
            sequenceState = .escaping
        }

        scene.performWindowEscape {
            scene.session.completeWindowEscape()
            withAnimation(.easeOut(duration: 0.8)) {
                sequenceState = .playing
            }
        }
    }

    private func playAgain() {
        let newScene = Self.makeScene()

        isIntroDismissing = false
        cutsceneOpacity = 0
        sequenceState = .playing
        scene = newScene
        newScene.session.start()
    }

    private static func makeScene() -> RoomScene {
        RoomScene(config: roomConfig, zoomScale: 600 / 437)
    }
}

#Preview(
    traits: .fixedLayout(width: 402, height: 874),
    .portrait
) {
    GameView()
}
