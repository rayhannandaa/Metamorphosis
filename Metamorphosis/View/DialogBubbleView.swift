import SwiftUI

/// Shared dialogue presentation used by intro and object monologues.
/// Intro bubbles omit the heading; interactable bubbles supply the object name.
struct DialogBubbleView: View {
    let heading: String?
    let text: String
    let hint: String
    @Binding private var isTextComplete: Bool
    let revealRequest: Int

    @State private var displayedText = ""
    @State private var typingTask: Task<Void, Never>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        heading: String? = nil,
        text: String,
        hint: String,
        isTextComplete: Binding<Bool>,
        revealRequest: Int
    ) {
        self.heading = heading
        self.text = text
        self.hint = hint
        _isTextComplete = isTextComplete
        self.revealRequest = revealRequest
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                if let heading, !heading.isEmpty {
                    Text(heading.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .foregroundStyle(Color(hex: "151515").opacity(0.55))
                        .tracking(2)
                }

                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .overlay(alignment: .topLeading) {
                        Text(displayedText)
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundStyle(Color(hex: "151515"))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityLabel(text)

                Text(hint)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(Color(hex: "151515").opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(isTextComplete ? 1 : 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "FFFEF4"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "2D1B11"), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        .onAppear {
            beginTyping()
        }
        .onChange(of: text) { _, _ in
            beginTyping()
        }
        .onChange(of: revealRequest) { _, _ in
            revealFullText()
        }
        .onDisappear {
            typingTask?.cancel()
        }
    }

    private func beginTyping() {
        typingTask?.cancel()
        displayedText = ""
        isTextComplete = false

        guard !reduceMotion else {
            revealFullText()
            return
        }

        let characters = Array(text)
        typingTask = Task { @MainActor in
            for character in characters {
                do {
                    try await Task.sleep(for: .milliseconds(30))
                } catch {
                    return
                }

                guard !Task.isCancelled else { return }
                displayedText.append(character)
            }

            isTextComplete = true
        }
    }

    private func revealFullText() {
        typingTask?.cancel()
        displayedText = text
        isTextComplete = true
    }
}
