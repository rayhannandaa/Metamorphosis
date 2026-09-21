import SpriteKit
import SwiftUI
import Foundation

struct GameView: View {
    private static let roomConfig = RoomConfig.room
    private let scene = RoomScene(config: roomConfig, zoomScale: 600 / 437)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "131313")

                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                HUDView()
            }
        }
        .ignoresSafeArea()
    }
}

private struct HUDView: View {
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
                        )
                    ) { }
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
}

private struct HUDButtonConfig {
    let name: String
    let assetName: String
    let size: CGSize
    let position: CGPoint
}

private extension Array where Element == HUDButtonConfig {
    static let roomHUD: [HUDButtonConfig] = [
        HUDButtonConfig(
            name: "ActionButton",
            assetName: "ActionButton",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 327, y: 736.35)
        ),
        HUDButtonConfig(
            name: "Right",
            assetName: "Right",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 185, y: 736.35)
        ),
        HUDButtonConfig(
            name: "Left",
            assetName: "Left",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 75, y: 736.35)
        ),
        HUDButtonConfig(
            name: "Down",
            assetName: "Down",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 130, y: 795.15)
        ),
        HUDButtonConfig(
            name: "Up",
            assetName: "Up",
            size: CGSize(width: 50, height: 57.7),
            position: CGPoint(x: 130, y: 677.45)
        )
    ]
}

private struct PressableButton: View {
    let assetName: String
    let size: CGSize
    let action: () -> Void

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
                    }
                    .onEnded { _ in
                        action()
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
