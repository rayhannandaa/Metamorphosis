import SwiftUI

struct ASARYUNIntroRootView: View {

    @State private var showGame = false

    var body: some View {

        if showGame {

            GameView()

        } else {

            ASARYUNIntroView {

                showGame = true
            }
        }
    }
}
