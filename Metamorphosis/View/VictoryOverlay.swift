//
//  VictoryOverlay.swift
//  Metamorphosis
//

import SwiftUI

struct VictoryOverlay: View {
    @ObservedObject var session: GameSessionController
    let onPlayAgain: () -> Void
    @State private var isPresented = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.91, blue: 0.65),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(isPresented ? 1 : 0)
            .animation(.easeInOut(duration: 0.8), value: isPresented)

            VStack(spacing: 0) {
                Text("METAMORPHOSIS COMPLETE")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(red: 0.42, green: 0.20, blue: 0.08))

                Text("You survived, transformed, and escaped the room.")
                    .font(.system(size: 18, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black.opacity(0.72))
                    .padding(.horizontal, 38)
                    .padding(.top, 16)

                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.system(size: 19, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.42, green: 0.20, blue: 0.08))
                        .clipShape(Capsule())
                }
                .padding(.top, 48)
            }
            .padding(.horizontal, 24)
            .opacity(isPresented ? 1 : 0)
            .scaleEffect(isPresented ? 1 : 0.96)
            .offset(y: isPresented ? 0 : 14)
            .animation(
                .easeOut(duration: 0.65).delay(0.2),
                value: isPresented
            )
        }
        .allowsHitTesting(session.isVictory && isPresented)
        .onChange(of: session.isVictory, initial: true) { _, isVictory in
            isPresented = isVictory
        }
    }
}
