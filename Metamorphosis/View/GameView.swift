import SpriteKit
import SwiftUI

struct GameView: View {
    private static let roomConfig = RoomConfig.room
    private let scene = RoomScene(config: roomConfig)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "131313")

                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(
                        width: min(Self.roomConfig.sceneSize.width, geometry.size.width),
                        height: geometry.size.height
                    )
                    .clipped()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview(
    traits: .fixedLayout(width: 874, height: 402),
    .landscapeLeft
) {
    GameView()
}
