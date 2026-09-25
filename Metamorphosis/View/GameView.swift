import SpriteKit
import SwiftUI
import Foundation

struct GameView: View {
    private static let roomConfig = RoomConfig.room
    private let scene = RoomScene(config: roomConfig, zoomScale: 600 / 437)
    
    @State private var showIntroMonologue = true
    
    // Smooth Cutscene states
    @State private var isShowingCutscene: Bool = false
    @State private var cutsceneOpacity: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "131313")

                // ALWAYS render the game in the background so it can fade in/out
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                if !isShowingCutscene {
                    HUDView(scene: scene)
                    ASARYUNHUDOverlay(session: scene.asaryunSession)
                    MonologueObserver(manager: scene.interactableManager)
                }
                
                if showIntroMonologue {
                    GameIntroMonologueOverlay(
                        text: "What happened, why did I suddenly shrink",
                        onDismiss: { showIntroMonologue = false }
                    )
                }
                
                // THE CINEMATIC FADE OVERLAY
                if isShowingCutscene {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        Image("Cocoon") // Uses your asset natively
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .offset(y: -20)
                    }
                    .opacity(cutsceneOpacity)
                    .allowsHitTesting(true)
                }
            }
        }
        .ignoresSafeArea()
        // Listen to the ACTUAL game session day to trigger the event
        .onChange(of: scene.asaryunSession.day) { _, newDay in
            if newDay == 2 {
                isShowingCutscene = true
                
                // 1. Fade Out into Black
                withAnimation(.easeInOut(duration: 2.0)) {
                    cutsceneOpacity = 1.0
                }
                
                // 2. Wait 4 seconds, skip the background game session directly to Day 3
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    scene.asaryunSession.skipToDay(3)
                    
                    // 3. Fade In back to the gameplay
                    withAnimation(.easeInOut(duration: 2.5)) {
                        cutsceneOpacity = 0.0
                    }
                    
                    // 4. Clean up the overlay view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isShowingCutscene = false
                    }
                }
            }
        }
    }
}

private struct GameIntroMonologueOverlay: View {
    let text: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.45)
                .ignoresSafeArea()

            ASARYUNDialogBubble(
                text: text,
                hint: "Tap to continue"
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onDismiss()
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
                        onRelease: { setDirection(button.direction, isActive: false) }
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

    @State private var isPressed = false
    @State private var pressBeganAt: Date?
    @State private var pressGeneration = 0

    private let minimumPressDuration: TimeInterval = 0.08

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
                        onRelease()
                        finishVisualPress()
                    }
            )
    }

    private func finishVisualPress() {
        let elapsed = pressBeganAt.map { Date().timeIntervalSince($0) } ?? minimumPressDuration
        let remainingDuration = max(0, minimumPressDuration - elapsed)
        let completedGeneration = pressGeneration

        guard remainingDuration > 0 else {
            isPressed = false
            pressBeganAt = nil
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
            guard pressGeneration == completedGeneration else { return }
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
    
    var body: some View {
        if let monologue = manager.activeMonologue {
            MonologueOverlayView(
                objectName: monologue.objectName,
                monologueText: monologue.text,
                onDismiss: { manager.dismissMonologue() }
            )
        }
    }
}
