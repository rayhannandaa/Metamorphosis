//
//  GameStatusOverlay.swift
//  Gameplay
//
//  Self-contained SwiftUI overlay for the game status.
//

import SwiftUI

struct GameStatusOverlay: View {
    @ObservedObject var session: GameSessionController

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                Text(session.displayTime)
                    .monospacedDigit()

                Text(session.isDaytime ? "☀️" : "🌙")

                Text("Day \(session.day)/\(session.totalDays)")

                Text(phaseEmoji + " " + session.phase.displayName)
            }
            .font(.caption.bold())
            .foregroundColor(.white)

            barRow(label: "Stress", value: session.stressValue, color: .red)

            if session.phase == .worm {
                barRow(label: "Hunger", value: session.hungerValue, color: .green)
            }

            if session.isGameComplete {
                Text("🦋 Metamorphosis complete")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.black.opacity(0.35))
        .cornerRadius(12)
        // Safe-area aware placement: lower than the iPhone Dynamic Island.
        .padding(.top, 58)
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .allowsHitTesting(false)
    }

    private var phaseEmoji: String {
        switch session.phase {
        case .worm: return "🐛"
        case .pupa: return "🛖"
        case .butterfly: return "🦋"
        }
    }

    private func barRow(label: String, value: CGFloat, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: 46, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(color)
                        .frame(
                            width: geometry.size.width *
                            max(0, min(1, value / GameConfig.maxBarValue))
                        )
                }
            }
            .frame(width: 120, height: 10)
        }
    }
}
