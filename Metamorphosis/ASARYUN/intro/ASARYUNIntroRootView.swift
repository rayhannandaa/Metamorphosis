import SwiftUI

struct ASARYUNIntroRootView: View {

    @State private var showGame = false

    var body: some View {
        ZStack {
            if showGame {
                GameView()
                    .transition(.opacity)
            } else {
                ASARYUNIntroView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showGame = true
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showGame)
    }
}
