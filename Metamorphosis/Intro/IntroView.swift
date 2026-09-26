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
    @State private var isTextComplete = false
    @State private var revealRequest = 0
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

            if isDialogVisible && !isFinalBlack {
                DialogBubbleView(
                    text: Self.monologues[currentMonologueIndex],
                    hint: "Tap to continue",
                    isTextComplete: $isTextComplete,
                    revealRequest: revealRequest
                )
                .transition(
                    reduceMotion
                        ? .opacity
                        : .move(edge: .bottom).combined(with: .opacity)
                )
            }
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

        guard isTextComplete else {
            revealRequest += 1
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

        isTextComplete = false
        currentMonologueIndex = monologueIndex

        withAnimation(.easeInOut(duration: 0.45)) {
            isTransitionDarkened = true
            if entersDarkSequence {
                isDarkSequence = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.easeOut(duration: 0.35)) {
                isTransitionDarkened = false
            }

            isTransitioning = false
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
                    startRadiusMultiplier: 0.18,
                    endRadiusMultiplier: 0.72,
                    middleOpacity: 0.16,
                    edgeOpacity: 0.86
                )

                vignette(
                    shortestSide: shortestSide,
                    startRadiusMultiplier: 0.07,
                    endRadiusMultiplier: 0.50,
                    middleOpacity: 0.30,
                    edgeOpacity: 0.96
                )
                .opacity(isContracted ? 1 : 0)
            }
            .animation(
                .easeInOut(duration: 3.7).repeatForever(autoreverses: true),
                value: isContracted
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func vignette(
        shortestSide: CGFloat,
        startRadiusMultiplier: CGFloat,
        endRadiusMultiplier: CGFloat,
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
            startRadius: shortestSide * startRadiusMultiplier,
            endRadius: shortestSide * endRadiusMultiplier
        )
    }
}
