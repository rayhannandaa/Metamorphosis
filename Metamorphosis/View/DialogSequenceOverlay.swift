import SwiftUI

struct DialogSequenceOverlay: View {
    let sequence: DialogSequence
    var onDismissStarted: () -> Void = {}
    let onDismiss: () -> Void

    @State private var lineIndex = 0
    @State private var isPresented = false

    private let animationDuration = 0.3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(isPresented ? 0.4 : 0)
                    .ignoresSafeArea()

                DialogBubbleView(
                    text: sequence.lines[lineIndex],
                    hint: "Tap to continue"
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

            if lineIndex < sequence.lines.count - 1 {
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
