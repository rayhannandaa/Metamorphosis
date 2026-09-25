import SpriteKit
import SwiftUI
import Foundation

struct GameView: View {
    private static let roomConfig = RoomConfig.room
    @State private var scene: RoomScene
    
    @State private var showIntroMonologue = true
    @State private var isIntroDismissing = false
    
    // Smooth Cutscene states
    @State private var isShowingCutscene: Bool = false
    @State private var cutsceneOpacity: Double = 0.0

    init() {
        _scene = State(initialValue: Self.makeScene())
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "131313")

                // ALWAYS render the game in the background so it can fade in/out
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .id(ObjectIdentifier(scene))

                DayTwoCutsceneTrigger(session: scene.asaryunSession) {
                    beginDayTwoCutscene()
                }
                .id(ObjectIdentifier(scene.asaryunSession))

                if !isShowingCutscene {
                    GameplayOverlay(
                        scene: scene,
                        isIntroBlockingHUD: showIntroMonologue && !isIntroDismissing
                    )
                    .id(ObjectIdentifier(scene))
                }
                
                if showIntroMonologue {
                    GameIntroMonologueOverlay(
                        text: "What happened, why did I suddenly shrink",
                        onDismissStarted: {
                            isIntroDismissing = true
                        },
                        onDismiss: {
                            showIntroMonologue = false
                            isIntroDismissing = false
                            scene.asaryunSession.start()
                        }
                    )
                }
                
                // THE CINEMATIC FADE OVERLAY
                if isShowingCutscene {
                    DayTwoCutsceneView {
                        finishDayTwoCutscene()
                    }
                    .opacity(cutsceneOpacity)
                    .allowsHitTesting(true)
                }

                ASARYUNSurvivalOverlay(
                    session: scene.asaryunSession,
                    onPlayAgain: playAgain
                )
                .id(ObjectIdentifier(scene.asaryunSession))
            }
        }
        .ignoresSafeArea()
    }

    private func beginDayTwoCutscene() {
        scene.asaryunSession.pause()
        scene.setPlayerVisible(false)
        isShowingCutscene = true

        withAnimation(.easeInOut(duration: 2.0)) {
            cutsceneOpacity = 1.0
        }
    }

    private func finishDayTwoCutscene() {
        scene.asaryunSession.skipToDay(3)
        scene.setPlayerVisible(true)

        withAnimation(.easeInOut(duration: 2.5)) {
            cutsceneOpacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isShowingCutscene = false
            scene.asaryunSession.start()
        }
    }

    private func playAgain() {
        let newScene = Self.makeScene()

        showIntroMonologue = false
        isIntroDismissing = false
        isShowingCutscene = false
        cutsceneOpacity = 0
        scene = newScene
        newScene.asaryunSession.start()
    }

    private static func makeScene() -> RoomScene {
        RoomScene(config: roomConfig, zoomScale: 600 / 437)
    }
}

private struct DayTwoCutsceneTrigger: View {
    @ObservedObject var session: ASARYUNGameSessionController
    let onDayTwo: () -> Void

    @State private var hasTriggered = false

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .onChange(of: session.day, initial: true) { _, newDay in
                guard newDay == 2, !hasTriggered else { return }
                hasTriggered = true
                onDayTwo()
            }
    }
}

private struct GameIntroMonologueOverlay: View {
    let text: String
    let onDismissStarted: () -> Void
    let onDismiss: () -> Void
    @State private var isPresented = false

    private let animationDuration = 0.3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(isPresented ? 0.45 : 0)
                    .ignoresSafeArea()

                ASARYUNDialogBubble(
                    text: text,
                    hint: "Tap to continue"
                )
                .offset(y: isPresented ? 0 : geometry.size.height)
            }
        }
        .contentShape(Rectangle())
        .animation(.easeOut(duration: animationDuration), value: isPresented)
        .onAppear {
            isPresented = true
        }
        .onTapGesture {
            guard isPresented else { return }
            onDismissStarted()
            isPresented = false
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                onDismiss()
            }
        }
    }
}

private struct GameplayOverlay: View {
    let scene: RoomScene
    let isIntroBlockingHUD: Bool
    @ObservedObject private var interactableManager: InteractableManager
    @State private var isMonologueDismissing = false

    init(scene: RoomScene, isIntroBlockingHUD: Bool) {
        self.scene = scene
        self.isIntroBlockingHUD = isIntroBlockingHUD
        _interactableManager = ObservedObject(
            wrappedValue: scene.interactableManager
        )
    }

    private var areControlsVisible: Bool {
        !isIntroBlockingHUD && (
            interactableManager.activeMonologue == nil || isMonologueDismissing
        )
    }

    var body: some View {
        ZStack {
            HUDView(scene: scene)
                .opacity(areControlsVisible ? 1 : 0)
                .allowsHitTesting(areControlsVisible)
                .animation(.easeInOut(duration: 0.2), value: areControlsVisible)

            ASARYUNHUDOverlay(session: scene.asaryunSession)
                .opacity(isIntroBlockingHUD ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: isIntroBlockingHUD)

            MonologueObserver(
                manager: interactableManager,
                onDismissalStateChange: { isDismissing in
                    isMonologueDismissing = isDismissing
                }
            )
        }
    }
}

private struct HUDView: View {
    let scene: RoomScene
    private let artboardSize = CGSize(width: 402, height: 874)
    private let buttons: [HUDButtonConfig] = .roomHUD

    var body: some View {
        GeometryReader { geometry in
            let scaleX = geometry.size.width / artboardSize.width
            let scaleY = geometry.size.height / artboardSize.height

            ZStack(alignment: .topLeading) {
                ForEach(buttons, id: \.name) { button in
                    PressableButton(
                        assetName: button.assetName,
                        size: CGSize(
                            width: button.size.width * scaleX,
                            height: button.size.height * scaleY
                        ),
                        onPress: {
                            if button.name == "ActionButton" {
                                scene.interactableManager.triggerInteraction(
                                    phase: scene.asaryunSession.phase,
                                    isDaytime: scene.asaryunSession.isDaytime
                                )
                            } else {
                                setDirection(button.direction, isActive: true)
                            }
                        },
                        onRelease: {
                            setDirection(button.direction, isActive: false)
                        },
                        onQuickTap: {
                            guard let direction = button.direction else { return }
                            scene.advanceWormStepFrame(direction)
                        }
                    )
                    .position(
                        x: button.position.x * scaleX,
                        y: button.position.y * scaleY
                    )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .topLeading
            )
        }
    }

    private func setDirection(_ direction: MovementDirection?, isActive: Bool) {
        guard let direction else { return }
        scene.setMovementDirection(direction, isActive: isActive)
    }
}

private struct HUDButtonConfig {
    let name: String
    let assetName: String
    let size: CGSize
    let position: CGPoint
    let direction: MovementDirection?
}

private extension Array where Element == HUDButtonConfig {
    static let roomHUD: [HUDButtonConfig] = [
        HUDButtonConfig(
            name: "ActionButton",
            assetName: "ActionButton",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 327, y: 736.35),
            direction: nil
        ),
        HUDButtonConfig(
            name: "Right",
            assetName: "Right",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 185, y: 736.35),
            direction: .right
        ),
        HUDButtonConfig(
            name: "Left",
            assetName: "Left",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 75, y: 736.35),
            direction: .left
        ),
        HUDButtonConfig(
            name: "Down",
            assetName: "Down",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 130, y: 795.15),
            direction: .down
        ),
        HUDButtonConfig(
            name: "Up",
            assetName: "Up",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 130, y: 677.45),
            direction: .up
        )
    ]
}

private struct PressableButton: View {
    let assetName: String
    let size: CGSize
    var onPress: () -> Void = {}
    var onRelease: () -> Void = {}
    var onQuickTap: () -> Void = {}

    @State private var isPressed = false
    @State private var pressBeganAt: Date?
    @State private var pressGeneration = 0

    private let minimumPressDuration: TimeInterval = 0.08
    private let quickTapMaximumDuration: TimeInterval = 0.18

    var body: some View {
        Image(assetName)
            .resizable()
            .frame(width: size.width, height: size.height)
            .opacity(0.75)
            .contentShape(Rectangle())
            .offset(y: isPressed ? 5 : 0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        pressBeganAt = Date()
                        pressGeneration += 1
                        onPress()
                    }
                    .onEnded { _ in
                        finishPress()
                    }
            )
    }

    private func finishPress() {
        let elapsed = pressBeganAt.map { Date().timeIntervalSince($0) } ?? minimumPressDuration
        let remainingDuration = max(0, minimumPressDuration - elapsed)
        let completedGeneration = pressGeneration
        let isQuickTap = elapsed <= quickTapMaximumDuration

        guard remainingDuration > 0 else {
            onRelease()
            if isQuickTap {
                onQuickTap()
            }
            isPressed = false
            pressBeganAt = nil
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
            guard pressGeneration == completedGeneration else { return }
            onRelease()
            if isQuickTap {
                onQuickTap()
            }
            isPressed = false
            pressBeganAt = nil
        }
    }
}

#Preview(
    traits: .fixedLayout(width: 402, height: 874),
    .portrait
) {
    GameView()
}

struct MonologueObserver: View {
    @ObservedObject var manager: InteractableManager
    let onDismissalStateChange: (Bool) -> Void
    
    var body: some View {
        if let monologue = manager.activeMonologue {
            MonologueOverlayView(
                objectName: monologue.objectName,
                monologueText: monologue.text,
                onDismissStarted: {
                    onDismissalStateChange(true)
                },
                onDismiss: {
                    manager.dismissMonologue()
                    onDismissalStateChange(false)
                }
            )
        }
    }
}
