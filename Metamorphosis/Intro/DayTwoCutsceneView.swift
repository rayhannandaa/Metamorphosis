//
//  DayTwoCutsceneView.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 25/09/26.
//


import SwiftUI

struct DayTwoCutsceneView: View {
    let onContinue: () -> Void

    @StateObject private var shakeDetector = SustainedShakeDetector()
    @State private var showDialog = false
    @State private var showShakeInstruction = false
    @State private var isCompleting = false
    @State private var dialogIndex = 0
    @State private var isTextComplete = false
    @State private var revealRequest = 0

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
                    hint: "Tap to continue",
                    isTextComplete: $isTextComplete,
                    revealRequest: revealRequest
                )
                .transition(.move(edge: .bottom))
            }

            if showShakeInstruction {
                VStack {
                    Text("Keep shaking your phone to break free")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(hex: "151515"))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 13)
                        .background(
                            Capsule()
                                .fill(Color(hex: "FFFEF4"))
                                .overlay(
                                    Capsule()
                                        .stroke(Color(hex: "2D1B11"), lineWidth: 1.5)
                                )
                        )
                        .contentShape(Capsule())
                        .onTapGesture {
                            completeCutscene()
                        }

                    Spacer()
                }
                .padding(.top, 70)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .contentShape(Rectangle())
        .animation(
            .easeOut(duration: dialogAnimationDuration),
            value: showDialog
        )
        .animation(
            .spring(response: 0.35, dampingFraction: 0.75),
            value: showShakeInstruction
        )
        .onTapGesture {
            guard showDialog, !isCompleting else { return }

            guard isTextComplete else {
                revealRequest += 1
                return
            }

            if dialogIndex < dialogs.count - 1 {
                isTextComplete = false
                dialogIndex += 1
                return
            }

            showDialog = false

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(dialogAnimationDuration))
                guard !isCompleting else { return }
                showShakeInstruction = true
                shakeDetector.start {
                    completeCutscene()
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.0))
            guard !isCompleting else { return }
            showDialog = true
        }
        .onDisappear {
            shakeDetector.stop()
        }
    }

    private func completeCutscene() {
        guard showShakeInstruction, !isCompleting else { return }
        isCompleting = true
        shakeDetector.stop()

        withAnimation(.easeInOut(duration: dialogAnimationDuration)) {
            showShakeInstruction = false
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(dialogAnimationDuration))
            onContinue()
        }
    }
}
