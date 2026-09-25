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

//
//  ASARYUNGameSessionController.swift
//  ASARYUN
//

import SpriteKit
import Combine

final class ASARYUNGameSessionController: NSObject, ObservableObject, SKPhysicsContactDelegate {
    @Published private(set) var day: Int = 1
    @Published private(set) var totalDays: Int = ASARYUNGameConfig.totalDemoDays
    @Published private(set) var phase: ASARYUNGamePhase = .worm
    @Published private(set) var isDaytime: Bool = true
    @Published private(set) var displayTime: String = "06:00"
    @Published private(set) var stressValue: CGFloat = 0
    @Published private(set) var hungerValue: CGFloat = ASARYUNGameConfig.initialHungerValue
    @Published private(set) var isGameComplete: Bool = false
    @Published private(set) var isSurvivalWarning: Bool = false
    @Published private(set) var isDeathCountdownActive: Bool = false
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var deathCause: ASARYUNDeathCause?
    @Published private(set) var isEscapeRequested: Bool = false
    @Published private(set) var isVictory: Bool = false

    private let clock = ASARYUNGameClock()
    private let stress = ASARYUNStressManager()
    private let hunger = ASARYUNHungerManager()
    private let death = ASARYUNDeathManager()

    private weak var scene: SKScene?
    private weak var playerNode: SKNode?
    private var dayNight: ASARYUNDayNightController?
    private var foodNodes: [ASARYUNFoodNode] = []
    private var hasAttached = false
    private var isRunning = false
    private var hudRefreshAccumulator: TimeInterval = 0
    private var pendingStressValue: CGFloat = 0
    private var pendingHungerValue: CGFloat = ASARYUNGameConfig.initialHungerValue
    private var isFoodPlacementValid: ((CGPoint, CGSize) -> Bool)?

    private var isPlayerInSunlight = false
    private var sunExposureTimer: TimeInterval = 0

    func attach(
        scene: SKScene,
        playerNode: SKNode,
        windowPosition: CGPoint,
        windowSize: CGSize,
        sceneSize: CGSize,
        isFoodPlacementValid: @escaping (CGPoint, CGSize) -> Bool
    ) {
        guard !hasAttached else { return }
        hasAttached = true

        self.scene = scene
        self.playerNode = playerNode
        self.isFoodPlacementValid = isFoodPlacementValid

        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = .zero

        let body = SKPhysicsBody(rectangleOf: CGSize(width: 36, height: 46))
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = ASARYUNPhysicsCategory.player
        body.contactTestBitMask = ASARYUNPhysicsCategory.food
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
        clock.onGameComplete = { [weak self] in self?.pause() }

        stress.onChange = { [weak self] value in self?.pendingStressValue = value }
        hunger.onChange = { [weak self] value in self?.pendingHungerValue = value }

        pendingStressValue = stress.value
        pendingHungerValue = hunger.value
        displayTime = clock.displayTime

        spawnFood(count: ASARYUNGameConfig.foodPerDay)
    }

    /// Starts the day/night clock and survival systems after the intro ends.
    func start() {
        guard !isGameOver else { return }
        isRunning = true
    }

    /// Freezes the clock and survival systems during a full-screen cutscene.
    func pause() {
        isRunning = false
    }

    func requestWindowEscape() {
        guard phase == .butterfly, !isGameOver, !isVictory, !isEscapeRequested else { return }
        pause()
        isEscapeRequested = true
    }

    func beginWindowEscape() {
        guard isEscapeRequested, !isVictory else { return }
        isEscapeRequested = false
        pause()
    }

    func completeWindowEscape() {
        isEscapeRequested = false
        isGameComplete = true
        isVictory = true
        pause()
    }

    func update(deltaTime: TimeInterval) {
        guard isRunning, hasAttached, deltaTime.isFinite, deltaTime > 0 else { return }

        clock.update(deltaTime: deltaTime)
        if clock.currentPhase == .worm {
            updateSunExposure(deltaTime: deltaTime)
            hunger.update(deltaTime: deltaTime)
        } else {
            isPlayerInSunlight = false
            sunExposureTimer = 0
        }
        updateStress(deltaTime: deltaTime)

        updateDeathState(deltaTime: deltaTime)

        hudRefreshAccumulator += deltaTime
        if hudRefreshAccumulator >= ASARYUNGameConfig.hudUpdateInterval {
            hudRefreshAccumulator = 0
            stressValue = pendingStressValue
            hungerValue = pendingHungerValue
            displayTime = clock.displayTime
        }
    }
    
    // NEW MECHANIC: Allows the cutscene overlay to instantly fast-forward to Day 3
    func skipToDay(_ targetDay: Int) {
        clock.skipToDay(targetDay)
        day = clock.currentDay
        displayTime = clock.displayTime
        isDaytime = clock.isDaytime
        phase = clock.currentPhase
        dayNight?.setDaytime(isDaytime)
    }

    private func updateSunExposure(deltaTime: TimeInterval) {
        let playerPosition = playerNode?.position ?? .zero
        let isCurrentlyExposed = clock.isDaytime
            && (dayNight?.isPointInSunlight(playerPosition) ?? false)

        guard isCurrentlyExposed else {
            isPlayerInSunlight = false
            sunExposureTimer = 0
            return
        }

        if !isPlayerInSunlight {
            isPlayerInSunlight = true
            sunExposureTimer = 0
            stress.registerSunHit()
        }

        sunExposureTimer += deltaTime
        while sunExposureTimer >= ASARYUNGameConfig.stressSunIntervalSeconds {
            sunExposureTimer -= ASARYUNGameConfig.stressSunIntervalSeconds
            stress.registerSunHit()
        }
    }

    private func updateStress(deltaTime: TimeInterval) {
        guard !isPlayerInSunlight else { return }

        let decayRate = clock.isDaytime
            ? ASARYUNGameConfig.stressDecayPerSecond
            : ASARYUNGameConfig.nighttimeStressDecayPerSecond
        stress.update(
            deltaTime: deltaTime,
            decayPerSecond: decayRate
        )
    }

    private func updateDeathState(deltaTime: TimeInterval) {
        let status = death.update(
            stress: stress.value,
            hunger: hunger.value,
            monitorsHunger: clock.currentPhase == .worm,
            deltaTime: deltaTime
        )

        if isSurvivalWarning != status.isWarning {
            isSurvivalWarning = status.isWarning
        }
        if isDeathCountdownActive != status.isCountdownActive {
            isDeathCountdownActive = status.isCountdownActive
        }
        if deathCause != status.cause {
            deathCause = status.cause
        }

        guard status.didDie, !isGameOver else { return }
        stressValue = stress.value
        hungerValue = hunger.value
        isGameOver = true
        isRunning = false
    }

    private func handleDayNightChange(_ isDay: Bool) {
        isDaytime = isDay
        displayTime = clock.displayTime
        dayNight?.setDaytime(isDay)
        if !isDay {
            isPlayerInSunlight = false
            sunExposureTimer = 0
        }
    }

    private func handleSunRayTick(index: Int) {
        dayNight?.setSunRay(index: index)
    }

    private func handlePhaseChange(_ newPhase: ASARYUNGamePhase) {
        phase = newPhase
        
        // Fix: Pass the phase directly to the PlayerNode so it handles its own resolution/animations
        if let player = playerNode as? PlayerNode {
            player.currentPhase = newPhase
        }
    }

    private func handleNewDay(_ newDay: Int) {
        day = newDay
        stress.reset()
    }

    private func spawnFood(count: Int) {
        guard let scene else { return }
        let size = scene.size

        for _ in 0..<count {
            guard let kind = ASARYUNFoodKind.allCases.randomElement() else { continue }
            var spawnPosition: CGPoint?

            for _ in 0..<ASARYUNGameConfig.foodSpawnMaxAttempts {
                let candidate = CGPoint(
                    x: CGFloat.random(in: 60...(size.width - 60)),
                    y: CGFloat.random(in: 120...(size.height - 160))
                )

                let clearsRoomObjects = isFoodPlacementValid?(candidate, kind.size) ?? false
                let candidateFrame = CGRect(
                    x: candidate.x - kind.size.width / 2,
                    y: candidate.y - kind.size.height / 2,
                    width: kind.size.width,
                    height: kind.size.height
                ).insetBy(
                    dx: -ASARYUNGameConfig.foodSpawnClearance,
                    dy: -ASARYUNGameConfig.foodSpawnClearance
                )
                let clearsOtherFood = foodNodes.allSatisfy { food in
                    !candidateFrame.intersects(
                        food.frame.insetBy(
                            dx: -ASARYUNGameConfig.foodSpawnClearance,
                            dy: -ASARYUNGameConfig.foodSpawnClearance
                        )
                    )
                }

                if clearsRoomObjects && clearsOtherFood {
                    spawnPosition = candidate
                    break
                }
            }

            guard let spawnPosition else { continue }
            let food = ASARYUNFoodNode(position: spawnPosition, kind: kind)
            scene.addChild(food)
            foodNodes.append(food)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let categories = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if categories == (ASARYUNPhysicsCategory.player | ASARYUNPhysicsCategory.food) {
            let foodBody = contact.bodyA.categoryBitMask == ASARYUNPhysicsCategory.food ? contact.bodyA : contact.bodyB
            guard let foodNode = foodBody.node as? ASARYUNFoodNode else { return }
            if phase == .worm, let player = playerNode as? PlayerNode {
                player.playEatingAnimation()
            }
            hunger.feed()
            foodNode.removeFromParent()
            foodNodes.removeAll { $0 === foodNode }

            if foodNodes.isEmpty {
                spawnFood(count: ASARYUNGameConfig.foodPerDay)
            }
        }
    }

}
