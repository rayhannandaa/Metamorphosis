//
//  DayTwoCutsceneView.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 25/09/26.
//


import SwiftUI

struct DayTwoCutsceneView: View {
    let onContinue: () -> Void

    @State private var showDialog = false
    @State private var hasContinued = false
    @State private var dialogIndex = 0

    private let dialogAnimationDuration = 0.3
    private let dialogs = [
        "Why is it so dark?",
        "I can’t move my body…",
        "Something inside me is changing.",
        "Am I dying… or becoming something else?"
    ]
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())

            if showDialog {
                DialogBubbleView(
                    text: dialogs[dialogIndex],
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

            if dialogIndex < dialogs.count - 1 {
                dialogIndex += 1
                return
            }

            hasContinued = true
            showDialog = false

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(dialogAnimationDuration))
                onContinue()
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.0))
            guard !hasContinued else { return }
            showDialog = true
        }
    }
}
