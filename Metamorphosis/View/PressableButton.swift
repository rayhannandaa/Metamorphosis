import Foundation
import SwiftUI

struct PressableButton: View {
    let assetName: String
    let size: CGSize
    var onPress: () -> Void = {}
    var onRelease: () -> Void = {}
    var onQuickTap: () -> Void = {}

    @State private var isPressed = false
    @State private var pressBeganAt: Date?
    @State private var pressGeneration = 0

    private let minimumPressDuration: TimeInterval = 0.08
    private let quickTapMaximumDuration: TimeInterval = 0.18

    var body: some View {
        Image(assetName)
            .resizable()
            .frame(width: size.width, height: size.height)
            .opacity(0.75)
            .contentShape(Rectangle())
            .offset(y: isPressed ? 5 : 0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        pressBeganAt = Date()
                        pressGeneration += 1
                        onPress()
                    }
                    .onEnded { _ in
                        finishPress()
                    }
            )
            .onDisappear {
                cancelPress()
            }
    }

    private func finishPress() {
        let elapsed = pressBeganAt.map { Date().timeIntervalSince($0) }
            ?? minimumPressDuration
        let remainingDuration = max(0, minimumPressDuration - elapsed)
        let completedGeneration = pressGeneration
        let isQuickTap = elapsed <= quickTapMaximumDuration

        guard remainingDuration > 0 else {
            completePress(isQuickTap: isQuickTap)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
            guard pressGeneration == completedGeneration else { return }
            completePress(isQuickTap: isQuickTap)
        }
    }

    private func completePress(isQuickTap: Bool) {
        onRelease()
        if isQuickTap {
            onQuickTap()
        }
        isPressed = false
        pressBeganAt = nil
    }

    private func cancelPress() {
        guard isPressed else { return }
        pressGeneration += 1
        onRelease()
        isPressed = false
        pressBeganAt = nil
    }
}
