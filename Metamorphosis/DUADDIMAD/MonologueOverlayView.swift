//
//  MonologueOverlayView.swift
//  Metamorphosis
//

import SwiftUI

/// Overlay displaying the character's monologue when an object is interacted with.
struct MonologueOverlayView: View {
    let objectName: String
    let monologueText: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            ASARYUNDialogBubble(
                heading: objectName,
                text: monologueText,
                hint: "Tap to dismiss"
            )
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDismiss)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
        .animation(.easeOut(duration: 0.2), value: monologueText)
    }
}

#Preview {
    ZStack {
        Color.gray
        MonologueOverlayView(
            objectName: "Bed",
            monologueText: "Maybe I’ll sleep later when I’m tired...",
            onDismiss: {}
        )
    }
}
