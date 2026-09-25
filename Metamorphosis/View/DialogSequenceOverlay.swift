import SwiftUI

struct DialogSequenceOverlay: View {
    let sequence: DialogSequence
    var onDismissStarted: () -> Void = {}
    let onDismiss: () -> Void

    @State private var lineIndex = 0
    @State private var isPresented = false
    @State private var isTextComplete = false
    @State private var revealRequest = 0

    private let animationDuration = 0.3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(isPresented ? 0.4 : 0)
                    .ignoresSafeArea()

                DialogBubbleView(
                    text: sequence.lines[lineIndex],
                    hint: "Tap to continue",
                    isTextComplete: $isTextComplete,
                    revealRequest: revealRequest
                )
                .offset(y: isPresented ? 0 : geometry.size.height)
            }
        }
        .contentShape(Rectangle())
        .animation(.easeOut(duration: animationDuration), value: isPresented)
        .onAppear {
            isPresented = true
        }
        .onTapGesture {
            guard isPresented else { return }

            guard isTextComplete else {
                revealRequest += 1
                return
            }

            if lineIndex < sequence.lines.count - 1 {
                isTextComplete = false
                lineIndex += 1
                return
            }

            onDismissStarted()
            isPresented = false
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                onDismiss()
            }
        }
    }
}
