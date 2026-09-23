//
//  ASARYUNGameSessionController.swift
//  ASARYUN
//
//  Single entry point that wires every ASARYUN mechanic on top of the
//  existing RoomScene: the day/night cycle, the stress and hunger bars,
//  food spawning, and worm -> pupa -> butterfly phase transitions.
//
//  RoomScene only needs to create one of these, call `attach` once the
//  world is built, and call `update(deltaTime:)` from its own update
//  loop. Nothing about the existing room, player movement or animation
//  code is modified.
//
//  Published properties drive the SwiftUI HUD (ASARYUNHUDOverlay).
//

import SpriteKit
import Combine

final class ASARYUNGameSessionController: NSObject, ObservableObject, SKPhysicsContactDelegate {
    // MARK: HUD-facing state
    @Published private(set) var day: Int = 1
    @Published private(set) var totalDays: Int = ASARYUNGameConfig.totalDemoDays
    @Published private(set) var phase: ASARYUNGamePhase = .worm
    @Published private(set) var isDaytime: Bool = true
    @Published private(set) var displayTime: String = "06:00"
    @Published private(set) var stressValue: CGFloat = 0
    @Published private(set) var hungerValue: CGFloat = ASARYUNGameConfig.maxBarValue
    @Published private(set) var isGameComplete: Bool = false

    // MARK: Internals
    private let clock = ASARYUNGameClock()
    private let stress = ASARYUNStressManager()
    private let hunger = ASARYUNHungerManager()

    private weak var scene: SKScene?
    private weak var playerNode: SKNode?
    private var dayNight: ASARYUNDayNightController?
    private var foodNodes: [ASARYUNFoodNode] = []
    private var hasAttached = false
    private var hudRefreshAccumulator: TimeInterval = 0
    private var pendingStressValue: CGFloat = 0
    private var pendingHungerValue: CGFloat = ASARYUNGameConfig.maxBarValue

    // How many sun rays the worm is currently overlapping, and how long
    // it's been continuously standing in at least one of them.
    private var sunContactCount = 0
    private var sunExposureTimer: TimeInterval = 0

    /// Wires everything up. Call once, after the room has been built and
    /// the player node added to the scene.
    func attach(
        scene: SKScene,
        playerNode: SKNode,
        windowPosition: CGPoint,
        windowSize: CGSize,
        sceneSize: CGSize
    ) {
        guard !hasAttached else { return }
        hasAttached = true

        self.scene = scene
        self.playerNode = playerNode

        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = .zero

        // The worm only needs a physics body to detect overlap with sun
        // rays / food; it stays kinematic (isDynamic) but is never moved
        // by the physics engine itself since nothing applies forces to it.
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 36, height: 46))
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = ASARYUNPhysicsCategory.player
        body.contactTestBitMask = ASARYUNPhysicsCategory.sunRay | ASARYUNPhysicsCategory.food
        body.collisionBitMask = 0
        playerNode.physicsBody = body

        dayNight = ASARYUNDayNightController(
            scene: scene,
            windowPosition: windowPosition,
            windowSize: windowSize,
            sceneSize: sceneSize
        )

        clock.onDayNightChange = { [weak self] isDay in self?.handleDayNightChange(isDay) }
        clock.onSunRayTick = { [weak self] index in self?.handleSunRayTick(index: index) }
        clock.onPhaseChange = { [weak self] phase in self?.handlePhaseChange(phase) }
        clock.onNewDay = { [weak self] day in self?.handleNewDay(day) }
        clock.onGameComplete = { [weak self] in self?.isGameComplete = true }

        stress.onChange = { [weak self] value in self?.pendingStressValue = value }
        hunger.onChange = { [weak self] value in self?.pendingHungerValue = value }

        pendingStressValue = stress.value
        pendingHungerValue = hunger.value
        displayTime = clock.displayTime

        spawnFood(count: ASARYUNGameConfig.foodPerDay)
    }

    /// Drive every ASARYUN system forward. Call from RoomScene.update(_:).
    func update(deltaTime: TimeInterval) {
        guard hasAttached, deltaTime.isFinite, deltaTime > 0 else { return }

        clock.update(deltaTime: deltaTime)
        stress.update(deltaTime: deltaTime)
        if clock.currentPhase == .worm {
            hunger.update(deltaTime: deltaTime)
            updateSunExposure(deltaTime: deltaTime)
        } else {
            sunExposureTimer = 0
        }

        // SpriteKit still runs normally, but SwiftUI is not invalidated on
        // every game frame. This prevents the HUD from causing visible
        // refresh/jitter while the simulation continues smoothly.
        hudRefreshAccumulator += deltaTime
        if hudRefreshAccumulator >= ASARYUNGameConfig.hudUpdateInterval {
            hudRefreshAccumulator = 0
            stressValue = pendingStressValue
            hungerValue = pendingHungerValue
            displayTime = clock.displayTime
        }
    }

    /// While the worm keeps standing in a sun ray, stress ticks up again
    /// every `stressSunIntervalSeconds` instead of only once on contact.
    private func updateSunExposure(deltaTime: TimeInterval) {
        guard sunContactCount > 0 else {
            sunExposureTimer = 0
            return
        }
        sunExposureTimer += deltaTime
        while sunExposureTimer >= ASARYUNGameConfig.stressSunIntervalSeconds {
            sunExposureTimer -= ASARYUNGameConfig.stressSunIntervalSeconds
            stress.registerSunHit()
        }
    }

    // MARK: Clock callbacks
    private func handleDayNightChange(_ isDay: Bool) {
        isDaytime = isDay
        displayTime = clock.displayTime
        dayNight?.setDaytime(isDay)
        if !isDay {
            // Safety net: no sun rays exist at night, so exposure can't
            // still be active even if a contact's didEnd was ever missed.
            sunContactCount = 0
            sunExposureTimer = 0
        }
    }

    private func handleSunRayTick(index: Int) {
        dayNight?.setSunRay(index: index)
    }

    private func handlePhaseChange(_ newPhase: ASARYUNGamePhase) {
        phase = newPhase

        // Swap the visible sprite for pupa / butterfly without touching
        // PlayerNode's own animation system. The worm phase is left
        // completely alone so its walk-cycle keeps working as before.
        guard let spriteNode = playerNode as? SKSpriteNode else { return }
        switch newPhase {
        case .worm:
            break
        case .pupa:
            spriteNode.removeAllActions()
            spriteNode.texture = SKTexture(imageNamed: "ASARYUN_Pupa")
        case .butterfly:
            spriteNode.removeAllActions()
            spriteNode.texture = SKTexture(imageNamed: "ASARYUN_Butterfly")
        }
    }

    private func handleNewDay(_ newDay: Int) {
        day = newDay
        stress.reset()
        // Hunger and food both persist across the day/night boundary now —
        // hunger only resets when eaten, food only respawns when it runs out.
    }

    // MARK: Food
    private func spawnFood(count: Int) {
        guard let scene else { return }
        let size = scene.size
        for _ in 0..<count {
            let x = CGFloat.random(in: 60...(size.width - 60))
            let y = CGFloat.random(in: 120...(size.height - 160))
            let food = ASARYUNFoodNode(position: CGPoint(x: x, y: y))
            scene.addChild(food)
            foodNodes.append(food)
        }
    }

    // MARK: SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if categories == (ASARYUNPhysicsCategory.player | ASARYUNPhysicsCategory.sunRay) {
            guard phase == .worm else { return }
            sunContactCount += 1
        } else if categories == (ASARYUNPhysicsCategory.player | ASARYUNPhysicsCategory.food) {
            let foodBody = contact.bodyA.categoryBitMask == ASARYUNPhysicsCategory.food ? contact.bodyA : contact.bodyB
            guard let foodNode = foodBody.node as? ASARYUNFoodNode else { return }
            hunger.feed()
            foodNode.removeFromParent()
            foodNodes.removeAll { $0 === foodNode }

            // Only top the food back up once every piece has been eaten.
            if foodNodes.isEmpty {
                spawnFood(count: ASARYUNGameConfig.foodPerDay)
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        guard categories == (ASARYUNPhysicsCategory.player | ASARYUNPhysicsCategory.sunRay) else { return }
        sunContactCount = max(0, sunContactCount - 1)
    }
}
