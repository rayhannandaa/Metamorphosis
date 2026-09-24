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
            // Semi-transparent backdrop to focus on the dialogue
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(objectName)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                            .textCase(.uppercase)

                        Spacer()

                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    Text(monologueText)
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Spacer()
                        Text("Tap to dismiss")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 120) // Keep clear of lower D-pad/action buttons
            }
        }
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
