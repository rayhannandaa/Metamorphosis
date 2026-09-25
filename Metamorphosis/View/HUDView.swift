import SwiftUI

struct HUDView: View {
    @ObservedObject var viewModel: HUDViewModel

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
                            viewModel.handlePress(for: button)
                        },
                        onRelease: {
                            viewModel.handleRelease(for: button)
                        },
                        onQuickTap: {
                            viewModel.handleQuickTap(for: button)
                        }
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
}
