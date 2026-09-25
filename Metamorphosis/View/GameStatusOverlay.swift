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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(session.displayTime)
                    .monospacedDigit()

                Text(session.isDaytime ? "☀️" : "🌙")

                Text("Day \(session.day)/\(session.totalDays)")

                Text(phaseEmoji + " " + session.phase.displayName)
            }
            .font(.system(size: 14, weight: .semibold, design: .serif))
            .foregroundStyle(Color(hex: "FFFEF4"))

            barRow(
                label: "Stress",
                value: session.stressValue,
                color: Color(hex: "DE4B29")
            )

            if session.phase == .worm {
                barRow(
                    label: "Hunger",
                    value: session.hungerValue,
                    color: Color(hex: "C2D83F")
                )
            }

            if session.isGameComplete {
                Text("🦋 Metamorphosis complete")
                    .font(.system(size: 12, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(hex: "FFFEF4"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .serif))
                .foregroundStyle(Color(hex: "FFFEF4"))
                .frame(width: 56, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "FFFEF4").opacity(0.18))
                    Capsule()
                        .fill(color)
                        .frame(
                            width: geometry.size.width *
                            max(0, min(1, value / GameConfig.maxBarValue))
                        )
                }
            }
            .frame(width: 160, height: 14)
        }
    }
}
