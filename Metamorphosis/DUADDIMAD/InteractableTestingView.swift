//
//  InteractableTestingView.swift
//  Metamorphosis
//

import Combine
import SpriteKit
import SwiftUI

/// An interactive test scene dedicated to interactable objects.
/// Allows walking the character around the real room assets, observing proximity
/// feedback, and triggering monologues.
final class InteractableTestScene: SKScene {
    let interactableManager = InteractableManager()

    private let playerNode = SKShapeNode(rectOf: CGSize(width: 32, height: 42), cornerRadius: 4)
    private lazy var worldController = RoomWorldController(scene: self, config: .room)
    private var activeDirections: Set<MovementDirection> = []
    private var lastUpdateTime: TimeInterval?

    var currentPhase: ASARYUNGamePhase = .worm
    var isDaytime: Bool = true

    override init() {
        super.init(size: CGSize(width: 500, height: 800))
        scaleMode = .aspectFit
        backgroundColor = SKColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupWorld()
    }

    private func setupWorld() {
        // Room boundary border
        let roomRect = CGRect(x: 20, y: 30, width: 460, height: 740)
        let roomBorder = SKShapeNode(rect: roomRect, cornerRadius: 8)
        roomBorder.strokeColor = SKColor.white.withAlphaComponent(0.2)
        roomBorder.lineWidth = 2
        roomBorder.fillColor = SKColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1.0)
        roomBorder.zPosition = 0
        addChild(roomBorder)

        // Build the real room assets, then associate interactions with them.
        worldController.buildWorld()
        interactableManager.setupObjects(in: self)

        // Setup Player representation
        playerNode.fillColor = SKColor(red: 0.95, green: 0.75, blue: 0.25, alpha: 1.0)
        playerNode.strokeColor = .white
        playerNode.lineWidth = 1.5
        playerNode.position = CGPoint(x: 250, y: 350)
        playerNode.zPosition = 3.0

        let playerLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        playerLabel.text = "YOU"
        playerLabel.fontSize = 9
        playerLabel.fontColor = .black
        playerLabel.verticalAlignmentMode = .center
        playerLabel.horizontalAlignmentMode = .center
        playerNode.addChild(playerLabel)

        addChild(playerNode)
    }

    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdateTime = currentTime }
        guard let lastTime = lastUpdateTime else { return }
        let dt = currentTime - lastTime
        guard dt > 0, dt.isFinite else { return }

        updatePlayerMovement(dt: dt)
        interactableManager.update(playerPosition: playerNode.position)
    }

    func setDirection(_ direction: MovementDirection, isActive: Bool) {
        if isActive {
            activeDirections.insert(direction)
        } else {
            activeDirections.remove(direction)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        interactableManager.triggerInteraction(
            at: location,
            in: self,
            phase: currentPhase,
            isDaytime: isDaytime
        )
    }

    func teleportPlayer(to point: CGPoint) {
        playerNode.position = point
        interactableManager.update(playerPosition: point)
    }

    private func updatePlayerMovement(dt: TimeInterval) {
        var dx: CGFloat = 0
        var dy: CGFloat = 0

        if activeDirections.contains(.left) { dx -= 1 }
        if activeDirections.contains(.right) { dx += 1 }
        if activeDirections.contains(.up) { dy += 1 }
        if activeDirections.contains(.down) { dy -= 1 }

        guard dx != 0 || dy != 0 else { return }

        let length = (dx * dx + dy * dy).squareRoot()
        let speed: CGFloat = 160.0
        let step = speed * CGFloat(dt)

        playerNode.position.x = min(max(playerNode.position.x + (dx / length) * step, 40), 460)
        playerNode.position.y = min(max(playerNode.position.y + (dy / length) * step, 50), 750)
    }
}

/// SwiftUI test view for testing interactable objects, proximity animations, and monologues.
struct InteractableTestingView: View {
    @StateObject private var sceneHolder = SceneHolder()
    @State private var selectedPhase: ASARYUNGamePhase = .worm
    @State private var isDaytime: Bool = true
    @State private var showTeleportMenu = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 8) {
                // Top control bar: Phase & Day/Night selectors
                headerControlBar

                // SpriteKit view showing the room & interactables
                ZStack {
                    SpriteView(scene: sceneHolder.scene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(12)

                    // Proximity indicator toast
                    VStack {
                        if let nearby = sceneHolder.manager.nearbyObjectName {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 8, height: 8)
                                Text("NEAR: \(nearby.uppercased())")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.yellow.opacity(0.8), lineWidth: 1))
                            .padding(.top, 10)
                            .transition(.opacity)
                        }
                        Spacer()
                    }
                }

                // Bottom control panel: D-Pad, Teleport & Interact button
                bottomControlBar
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            // Monologue dialog overlay when triggered
            if let monologue = sceneHolder.manager.activeMonologue {
                MonologueOverlayView(
                    objectName: monologue.objectName,
                    monologueText: monologue.text,
                    onDismiss: {
                        sceneHolder.manager.dismissMonologue()
                    }
                )
            }
        }
//        .onChange(of: selectedPhase) { newPhase in
//            sceneHolder.scene.currentPhase = newPhase
//        }
//        .onChange(of: isDaytime) { newDay in
//            sceneHolder.scene.isDaytime = newDay
//        }
        
        .onChange(of: selectedPhase) { oldValue, newValue in
        sceneHolder.scene.currentPhase = newValue
        }
        .onChange(of: isDaytime) { oldValue, newValue in
        sceneHolder.scene.isDaytime = newValue
        }
    }

    // MARK: - Header Controls

    private var headerControlBar: some View {
        VStack(spacing: 6) {
            Text("Interactable Objects Test Harness")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 8) {
                // Phase picker
                Picker("Phase", selection: $selectedPhase) {
                    Text("Larvae (Worm)").tag(ASARYUNGamePhase.worm)
                    Text("Pupae").tag(ASARYUNGamePhase.pupa)
                    Text("Butterfly").tag(ASARYUNGamePhase.butterfly)
                }
                .pickerStyle(.segmented)

                // Time of day toggle
                Button(action: {
                    isDaytime.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isDaytime ? "sun.max.fill" : "moon.stars.fill")
                            .foregroundColor(isDaytime ? .yellow : .cyan)
                        Text(isDaytime ? "Day" : "Night")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(red: 0.15, green: 0.16, blue: 0.20))
        .cornerRadius(10)
    }

    // MARK: - Bottom Controls

    private var bottomControlBar: some View {
        HStack(alignment: .center, spacing: 20) {
            // Directional controls for player movement
            directionalDPad

            Spacer()

            // Teleport button to quickly jump between objects
            Menu {
                ForEach(InteractableObjectType.allCases) { type in
                    Button(type.displayName) {
                        if let position = sceneHolder.manager.position(for: type) {
                            sceneHolder.scene.teleportPlayer(to: position)
                        }
                    }
                }
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                    Text("Teleport")
                        .font(.system(size: 10, weight: .medium))
                }
                .frame(width: 58, height: 58)
                .background(Color.white.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(29)
            }

            // Interact Action button
            Button(action: {
                sceneHolder.manager.triggerInteraction(
                    phase: selectedPhase,
                    isDaytime: isDaytime
                )
            }) {
                VStack(spacing: 2) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 18))
                    Text("INTERACT")
                        .font(.system(size: 10, weight: .bold))
                }
                .frame(width: 72, height: 72)
                .background(
                    sceneHolder.manager.nearbyObjectName != nil
                        ? Color(red: 0.95, green: 0.55, blue: 0.15)
                        : Color.white.opacity(0.2)
                )
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        sceneHolder.manager.nearbyObjectName != nil ? Color.yellow : Color.clear,
                        lineWidth: 2
                    )
                )
                .shadow(
                    color: sceneHolder.manager.nearbyObjectName != nil ? Color.yellow.opacity(0.5) : Color.clear,
                    radius: 8
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.12, green: 0.13, blue: 0.16))
        .cornerRadius(12)
    }

    private var directionalDPad: some View {
        VStack(spacing: 2) {
            dpadButton(direction: .up, icon: "arrow.up")
            HStack(spacing: 12) {
                dpadButton(direction: .left, icon: "arrow.left")
                Circle().fill(Color.white.opacity(0.1)).frame(width: 16, height: 16)
                dpadButton(direction: .right, icon: "arrow.right")
            }
            dpadButton(direction: .down, icon: "arrow.down")
        }
    }

    private func dpadButton(direction: MovementDirection, icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .bold))
            .frame(width: 38, height: 34)
            .background(Color.white.opacity(0.15))
            .foregroundColor(.white)
            .cornerRadius(6)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        sceneHolder.scene.setDirection(direction, isActive: true)
                    }
                    .onEnded { _ in
                        sceneHolder.scene.setDirection(direction, isActive: false)
                    }
            )
    }
}

private final class SceneHolder: ObservableObject {
    let scene = InteractableTestScene()
    var manager: InteractableManager {
        scene.interactableManager
    }
    private var cancellable: AnyCancellable?

    init() {
        cancellable = scene.interactableManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }
}

#Preview {
    InteractableTestingView()
}
