import SwiftUI

struct IntroRootView: View {

    @StateObject private var gameSceneStore = GameSceneStore()
    @StateObject private var flowCoordinator = GameFlowCoordinator()
    @State private var isIntroMounted = false
    @State private var isLoadingCoverMounted = true
    @State private var loadingCoverOpacity = 1.0
    @State private var isHandoffCoverMounted = false
    @State private var handoffCoverOpacity = 1.0
    @State private var hasCompletedOpeningHandoff = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            GameView(
                sceneStore: gameSceneStore,
                flowCoordinator: flowCoordinator
            )

            if isIntroMounted {
                IntroView {
                    finishOpeningIntro()
                }
            }

            if isHandoffCoverMounted {
                Color(hex: "080808")
                    .ignoresSafeArea()
                    .opacity(handoffCoverOpacity)
                    .allowsHitTesting(true)
            }

            if isLoadingCoverMounted {
                Color.black
                    .ignoresSafeArea()
                    .opacity(loadingCoverOpacity)
                    .allowsHitTesting(loadingCoverOpacity > 0.01)
            }
        }
        .onAppear {
            GameAudioManager.shared.startBackgroundMusic()

            GameAssetPreloader.preloadInitial {
                gameSceneStore.prepareInitialScene()
                flowCoordinator.transition(to: .openingIntro)
                isIntroMounted = true

                withAnimation(.easeInOut(duration: 0.35)) {
                    loadingCoverOpacity = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isLoadingCoverMounted = false
                }
            }
        }
    }

    private func finishOpeningIntro() {
        guard !hasCompletedOpeningHandoff else { return }
        hasCompletedOpeningHandoff = true
        handoffCoverOpacity = 1
        isHandoffCoverMounted = true

        // Let the opaque cover reach the display before changing any of the
        // content beneath it. This avoids fading the intro's translucent
        // vignette hierarchy, which could briefly composite as gray.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            var contentTransaction = Transaction()
            contentTransaction.disablesAnimations = true

            withTransaction(contentTransaction) {
                flowCoordinator.transition(to: .larvaDialogue)
                gameSceneStore.revealInitialContent()
                isIntroMounted = false
            }

            // Give SwiftUI and the already-mounted SpriteView one complete
            // frame to present the prepared gameplay state behind the cover.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    handoffCoverOpacity = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isHandoffCoverMounted = false
                    GameHapticsManager.shared.prepare()
                    GameAssetPreloader.preloadTransformation()
                }
            }
        }
    }
}
