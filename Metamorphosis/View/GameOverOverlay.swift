//
//  GameOverOverlay.swift
//  Metamorphosis
//
//  Survival warning vignette and the full-screen Game Over interface.
//

import SwiftUI

struct SurvivalOverlay: View {
    @ObservedObject var session: GameSessionController
    let onPlayAgain: () -> Void

    var body: some View {
        ZStack {
            if session.isSurvivalWarning && !session.isGameOver {
                CriticalVignette(
                    isLethal: session.isDeathCountdownActive
                )
                .transition(.opacity)
            }

            if session.isGameOver {
                GameOverOverlay(
                    cause: session.deathCause,
                    onPlayAgain: onPlayAgain
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.isSurvivalWarning)
        .animation(.easeInOut(duration: 0.3), value: session.isGameOver)
    }
}

private struct CriticalVignette: View {
    let isLethal: Bool
    @State private var isPulsing = false

    var body: some View {
        GeometryReader { geometry in
            let edgeDepth = min(geometry.size.width, geometry.size.height) * 0.24

            ZStack {
                edgeGradient(startPoint: .leading, endPoint: .trailing)
                    .frame(width: edgeDepth)
                    .frame(maxWidth: .infinity, alignment: .leading)

                edgeGradient(startPoint: .trailing, endPoint: .leading)
                    .frame(width: edgeDepth)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                edgeGradient(startPoint: .top, endPoint: .bottom)
                    .frame(height: edgeDepth)
                    .frame(maxHeight: .infinity, alignment: .top)

                edgeGradient(startPoint: .bottom, endPoint: .top)
                    .frame(height: edgeDepth)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .opacity(pulseOpacity)
            .animation(
                .easeInOut(duration: isLethal ? 0.42 : 0.75)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var pulseOpacity: Double {
        if isLethal {
            return isPulsing ? 0.9 : 0.55
        }
        return isPulsing ? 0.58 : 0.32
    }

    private func edgeGradient(
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> LinearGradient {
        LinearGradient(
            colors: [
                Color.red.opacity(isLethal ? 0.9 : 0.65),
                Color.red.opacity(0)
            ],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

private struct GameOverOverlay: View {
    let cause: DeathCause?
    let onPlayAgain: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("GAME OVER")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(.red)

                Text(cause?.message ?? "The transformation ended too soon.")
                    .font(.system(size: 18, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 38)
                    .padding(.top, 16)

                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.system(size: 19, weight: .semibold, design: .serif))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 48)
            }
            .foregroundStyle(.white)
        }
    }
}
