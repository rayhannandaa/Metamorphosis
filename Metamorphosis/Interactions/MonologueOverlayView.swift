//
//  MonologueOverlayView.swift
//  Metamorphosis
//

import Foundation
import SwiftUI

/// Overlay displaying the character's monologue when an object is interacted with.
struct MonologueOverlayView: View {
    let objectName: String
    let monologueText: String
    let onDismissStarted: () -> Void
    let onDismiss: () -> Void
    @State private var isPresented = false

    private let animationDuration = 0.3

    init(
        objectName: String,
        monologueText: String,
        onDismissStarted: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void
    ) {
        self.objectName = objectName
        self.monologueText = monologueText
        self.onDismissStarted = onDismissStarted
        self.onDismiss = onDismiss
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(isPresented ? 0.4 : 0)
                    .ignoresSafeArea()

                DialogBubbleView(
                    heading: objectName,
                    text: monologueText,
                    hint: "Tap to dismiss"
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
            onDismissStarted()
            isPresented = false
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                onDismiss()
            }
        }
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
