import SwiftUI

struct IntroView: View {

    // MARK: - Monologues

    private static let monologues = [
        "Something is wrong… my body feels different.",
        "My arms… my legs… I can’t feel them.",
        "Everything around me is becoming impossibly large.",
        "What is happening to me?"
    ]

    // MARK: - Properties

    private let onFinished: () -> Void

    @State private var currentMonologueIndex = 0
    @State private var isDarkSequence = false
    @State private var isFinalBlack = false
    @State private var hasFinished = false
    @State private var isRoomBreathing = false
    @State private var isDialogVisible = true
    @State private var isTransitionDarkened = false
    @State private var isTransitioning = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Opening room treatment remains mounted while it fades away.
            Color.black
                .opacity(0.38)
                .ignoresSafeArea()
                .opacity(isDarkSequence || isFinalBlack ? 0 : 1)

            // The dark-sequence background also remains mounted, preventing
            // SwiftUI from replacing the complete screen between lines.
            BlackMonologueBackground(
                isDarkened: isTransitionDarkened
            )
            .opacity(isDarkSequence && !isFinalBlack ? 1 : 0)

            // One continuous vignette is shared by every intro scene.
            IntroVignette(
                isContracted: isRoomBreathing && !reduceMotion
            )
            .opacity(isFinalBlack ? 0 : 1)

            Color(hex: "080808")
                .ignoresSafeArea()
                .opacity(isFinalBlack ? 1 : 0)

            DialogBubbleView(
                text: Self.monologues[currentMonologueIndex],
                hint: "Tap to continue"
            )
            .opacity(isDialogVisible && !isFinalBlack ? 1 : 0)
            .offset(
                y: isDialogVisible || reduceMotion ? 0 : 36
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            advance()
        }
        .onAppear {
            isRoomBreathing = true
        }
    }

    private func advance() {

        guard !hasFinished, !isTransitioning else {
            return
        }

        switch currentMonologueIndex {
        case 0:
            transitionTo(monologueIndex: 1, entersDarkSequence: true, playsThunder: false)
        case 1:
            transitionTo(monologueIndex: 2, entersDarkSequence: false, playsThunder: true)
        case 2:
            transitionTo(monologueIndex: 3, entersDarkSequence: false, playsThunder: true)
        case 3:
            finishIntro()
        default:
            break
        }
    }

    // MARK: - Mystery transition

    private func transitionTo(
        monologueIndex: Int,
        entersDarkSequence: Bool,
        playsThunder: Bool
    ) {
        isTransitioning = true

        if playsThunder {
            playThunder()
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            isDialogVisible = false
            isTransitionDarkened = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var textTransaction = Transaction()
            textTransaction.disablesAnimations = true
            withTransaction(textTransaction) {
                currentMonologueIndex = monologueIndex
            }

            if entersDarkSequence {
                withAnimation(.easeInOut(duration: 0.45)) {
                    isDarkSequence = true
                }
            }

            let revealDelay: TimeInterval = entersDarkSequence ? 0.45 : 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
                withAnimation(.easeOut(duration: 0.35)) {
                    isDialogVisible = true
                    isTransitionDarkened = false
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isTransitioning = false
                }
            }
        }
    }

    private func finishIntro() {
        hasFinished = true
        isTransitioning = true
        playThunder()

        withAnimation(.easeInOut(duration: 0.6)) {
            isDialogVisible = false
            isTransitionDarkened = true
            isFinalBlack = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onFinished()
        }
    }

    // MARK: - Thunder

    private func playThunder() {
        GameAudioManager.shared.playThunder()
    }
}

private struct BlackMonologueBackground: View {
    let isDarkened: Bool

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.025, blue: 0.03)
                .opacity(isDarkened ? 0.78 : 0.58)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.3), value: isDarkened)
    }
}

private struct IntroVignette: View {
    let isContracted: Bool

    var body: some View {
        GeometryReader { geometry in
            let shortestSide = min(geometry.size.width, geometry.size.height)

            ZStack {
                vignette(
                    shortestSide: shortestSide,
                    middleOpacity: 0.18,
                    edgeOpacity: 0.88
                )

                vignette(
                    shortestSide: shortestSide,
                    middleOpacity: 0.25,
                    edgeOpacity: 0.94
                )
                .opacity(isContracted ? 1 : 0)
            }
            .animation(
                .easeInOut(duration: 4.5).repeatForever(autoreverses: true),
                value: isContracted
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func vignette(
        shortestSide: CGFloat,
        middleOpacity: Double,
        edgeOpacity: Double
    ) -> RadialGradient {
        RadialGradient(
            colors: [
                Color.clear,
                Color.black.opacity(middleOpacity),
                Color.black.opacity(edgeOpacity)
            ],
            center: .center,
            startRadius: shortestSide * 0.12,
            endRadius: shortestSide * 0.62
        )
    }
}
