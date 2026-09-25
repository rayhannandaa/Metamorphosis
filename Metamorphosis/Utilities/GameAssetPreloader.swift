import SpriteKit

enum GameAssetPreloader {
    static func preloadInitial(completion: @escaping () -> Void) {
        let roomTextures = RoomConfig.room.objects.map(\.assetName)
        let initialGameplayTextures = [
            "Worm_N_0", "Worm_N_1",
            "Worm_E_0", "Worm_E_1",
            "Worm_W_0", "Worm_W_1",
            "Worm_Eats_L", "Worm_Eats_R", "Worm_Sleeps",
            "Watermelon", "Cheese", "Marker"
        ]

        preload(
            names: roomTextures + initialGameplayTextures,
            completion: completion
        )
    }

    static func preloadTransformation(completion: @escaping () -> Void = {}) {
        let transformationTextures = [
            "Cocoon",
            "Butterfly_N_0", "Butterfly_N_1",
            "Butterfly_N_2", "Butterfly_N_3",
            "Butterfly_E_0", "Butterfly_E_1",
            "Butterfly_E_2", "Butterfly_E_3",
            "Butterfly_W_0", "Butterfly_W_1",
            "Butterfly_W_2", "Butterfly_W_3"
        ]

        preload(names: transformationTextures, completion: completion)
    }

    private static func preload(
        names: [String],
        completion: @escaping () -> Void
    ) {
        let textures = Set(names).map(SKTexture.init(imageNamed:))

        SKTexture.preload(textures) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
