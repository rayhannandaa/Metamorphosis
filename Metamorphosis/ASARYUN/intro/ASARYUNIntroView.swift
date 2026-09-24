import AVFoundation
import SpriteKit
import SwiftUI

struct ASARYUNIntroView: View {

    // MARK: - Monologues

    private static let monologues = [
        "Something feels different...",
        "I don't remember how I got here.",
        "Everything is familiar, yet somehow impossibly large.",
        "Maybe I should stop trying to understand it... and just survive."
    ]

    // MARK: - Intro Steps

    private enum Step: Equatable {
        case roomMonologue
        case blackMonologue(Int)
        case flash
        case finalWhite
    }

    // MARK: - Properties

    private let onFinished: () -> Void
    private let scene: RoomScene

    @State private var step: Step = .roomMonologue
    @State private var hasFinished = false
    @State private var thunderPlayer: AVAudioPlayer?

    // MARK: - Init

    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished

        self.scene = RoomScene(
            config: .room,
            zoomScale: 600 / 437
        )

        self.scene.isPaused = true
    }

    // MARK: - Body

    var body: some View {
        ZStack {

            // Base black background
            Color.black
                .ignoresSafeArea()

            // Room background
            SpriteView(
                scene: scene,
                options: [.allowsTransparency]
            )
            .ignoresSafeArea()
            .opacity(step == .roomMonologue ? 1 : 0)

            switch step {

            // MARK: Room + Dark Overlay

            case .roomMonologue:

                Color.black
                    .opacity(0.62)
                    .ignoresSafeArea()

                ASARYUNDialogBubble(
                    text: Self.monologues[0],
                    hint: "Tap to continue"
                )

            // MARK: Black Screen Monologues

            case .blackMonologue(let index):

                Color.black
                    .ignoresSafeArea()

                ASARYUNDialogBubble(
                    text: Self.monologues[index],
                    hint: "Tap to continue"
                )

            // MARK: Flash

            case .flash:

                Color.white
                    .ignoresSafeArea()

            // MARK: Final White Screen

            case .finalWhite:

                Color.white
                    .ignoresSafeArea()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            advance()
        }
        .onAppear {
            scene.isPaused = true
        }
    }

    // MARK: - Advance Intro

    private func advance() {

        guard !hasFinished else {
            return
        }

        switch step {

        // Room → First Black Monologue

        case .roomMonologue:

            step = .blackMonologue(1)

        // First Black Monologue → Flash #1

        case .blackMonologue(1):

            flashThen {
                step = .blackMonologue(2)
            }

        // Second Black Monologue → Flash #2

        case .blackMonologue(2):

            flashThen {
                step = .blackMonologue(3)
            }

        // Third Black Monologue → Final White

        case .blackMonologue(3):

            hasFinished = true

            step = .finalWhite

            playThunder()

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.35
            ) {
                onFinished()
            }

        // Safety catch-all for any unexpected index

        case .blackMonologue(_):

            break

        // These states should not advance from tapping

        case .flash,
             .finalWhite:

            break
        }
    }

    // MARK: - Flash

    private func flashThen(completion: @escaping () -> Void) {
        step = .flash
        playThunder()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            completion()
        }
    }

    // MARK: - Thunder

    private func playThunder() {

        guard let url = Bundle.main.url(
            forResource: "ASARYUN_Intro_Thunder",
            withExtension: "wav"
        ) else {
            return
        }

        do {

            let player = try AVAudioPlayer(
                contentsOf: url
            )

            player.prepareToPlay()
            player.play()

            thunderPlayer = player

        } catch {

            thunderPlayer = nil
        }
    }
}
