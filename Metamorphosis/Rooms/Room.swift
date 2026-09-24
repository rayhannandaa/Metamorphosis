import CoreGraphics

extension RoomConfig {
    static let room = RoomConfig(
        sceneSize: CGSize(width: 500, height: 800),
        initialCameraPosition: CGPoint(x: 80, y: 567.55),
        objects: [
            RoomObjectConfig(
                name: "Floor",
                assetName: "Floor",
                size: CGSize(width: 460, height: 720),
                position: CGPoint(x: 250, y: 400),
                zPosition: 0
            ),
            RoomObjectConfig(
                name: "Walls",
                assetName: "Walls",
                size: CGSize(width: 460, height: 110),
                position: CGPoint(x: 250, y: 705),
                zPosition: 1
            ),
            RoomObjectConfig(
                name: "Sofa",
                assetName: "Sofa",
                size: CGSize(width: 130, height: 90),
                position: CGPoint(x: 100, y: 155),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Window",
                assetName: "Window",
                size: CGSize(width: 100, height: 87),
                position: CGPoint(x: 250, y: 713.5),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "WindowDay",
                assetName: "WindowDay",
                size: CGSize(width: 60, height: 57),
                position: CGPoint(x: 250, y: 718.5),
                zPosition: 2.1
            ),
            RoomObjectConfig(
                name: "WindowNight",
                assetName: "WindowNight",
                size: CGSize(width: 60, height: 57),
                position: CGPoint(x: 250, y: 718.5),
                zPosition: 2.2
            ),
            RoomObjectConfig(
                name: "Bed",
                assetName: "Bed",
                size: CGSize(width: 100, height: 154.9),
                position: CGPoint(x: 80, y: 567.55),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Table",
                assetName: "Table",
                size: CGSize(width: 100, height: 53),
                position: CGPoint(x: 420, y: 66.5),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Chair_1",
                assetName: "Chair",
                size: CGSize(width: 39, height: 36.6),
                position: CGPoint(x: 445, y: 116),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Chair_2",
                assetName: "Chair",
                size: CGSize(width: 39, height: 36.6),
                position: CGPoint(x: 285.5, y: 344.1),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Chair_3",
                assetName: "Chair",
                size: CGSize(width: 39, height: 36.6),
                position: CGPoint(x: 285.5, y: 410.7),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Wardrobe",
                assetName: "Wardrobe",
                size: CGSize(width: 96, height: 135.7),
                position: CGPoint(x: 422, y: 682.15),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "TableTwo",
                assetName: "TableTwo",
                size: CGSize(width: 140, height: 50),
                position: CGPoint(x: 100, y: 65),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "TableL",
                assetName: "TableL",
                size: CGSize(width: 150, height: 190),
                position: CGPoint(x: 405, y: 365),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Door",
                assetName: "Door",
                size: CGSize(width: 44.3, height: 155.2),
                position: CGPoint(x: 42.15, y: 337.4),
                zPosition: 2
            ),
            RoomObjectConfig(
                name: "Beanie",
                assetName: "Beanie",
                size: CGSize(width: 35, height: 36.9),
                position: CGPoint(x: 142.5, y: 81.55),
                zPosition: 2.1
            ),
            RoomObjectConfig(
                name: "Phone",
                assetName: "Phone",
                size: CGSize(width: 15, height: 25),
                position: CGPoint(x: 390.6, y: 80),
                zPosition: 2.1,
                rotation: 0 * .pi / 180
            ),
            RoomObjectConfig(
                name: "Photo",
                assetName: "Photo",
                size: CGSize(width: 50, height: 60.2),
                position: CGPoint(x: 435, y: 345.6),
                zPosition: 2.1
            ),
            RoomObjectConfig(
                name: "Laptop",
                assetName: "Laptop",
                size: CGSize(width: 33, height: 47.2),
                position: CGPoint(x: 356.5, y: 436.4),
                zPosition: 2.1,
                rotation: 0 * .pi / 180
            ),
            RoomObjectConfig(
                name: "WallsSide",
                assetName: "WallsSide",
                size: CGSize(width: 500, height: 800),
                position: CGPoint(x: 250, y: 400),
                zPosition: 3
            )
        ]
    )
}
