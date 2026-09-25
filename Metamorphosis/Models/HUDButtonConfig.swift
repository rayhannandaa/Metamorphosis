import CoreGraphics

struct HUDButtonConfig {
    let name: String
    let assetName: String
    let size: CGSize
    let position: CGPoint
    let direction: MovementDirection?
}

extension Array where Element == HUDButtonConfig {
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
