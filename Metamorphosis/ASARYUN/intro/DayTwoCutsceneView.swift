//
//  DayTwoCutsceneView.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 25/09/26.
//


import Foundation
import SwiftUI

struct DayTwoCutsceneView: View {
    let onContinue: () -> Void

    @State private var shakeOffset: CGFloat = -5.0
    @State private var showDialog = false
    @State private var hasContinued = false

    private let dialogAnimationDuration = 0.3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                Image("Cocoon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .offset(x: shakeOffset)
                    .animation(
                        .linear(duration: 0.05)
                            .repeatForever(autoreverses: true),
                        value: shakeOffset
                    )

                if showDialog {
                    ASARYUNDialogBubble(
                        text: "Why is it dark, why am I feeling sleepy...",
                        hint: "Tap to continue"
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .contentShape(Rectangle())
            .animation(
                .easeOut(duration: dialogAnimationDuration),
                value: showDialog
            )
            .onTapGesture {
                guard showDialog, !hasContinued else { return }
                hasContinued = true
                showDialog = false

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + dialogAnimationDuration
                ) {
                    onContinue()
                }
            }
            .onAppear {
                shakeOffset = 5.0

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    guard !hasContinued else { return }
                    showDialog = true
                }
            }
        }
    }
}
