struct RoomSceneDependencies {
    let interactableManager: InteractableManager
    let session: GameSessionController

    static func live() -> RoomSceneDependencies {
        RoomSceneDependencies(
            interactableManager: InteractableManager(),
            session: GameSessionController()
        )
    }
}
