import SwiftUI

/// Shared dialogue presentation used by intro and object monologues.
/// Intro bubbles omit the heading; interactable bubbles supply the object name.
struct DialogBubbleView: View {
    let heading: String?
    let text: String
    let hint: String

    init(
        heading: String? = nil,
        text: String,
        hint: String
    ) {
        self.heading = heading
        self.text = text
        self.hint = hint
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                if let heading, !heading.isEmpty {
                    Text(heading.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "151515").opacity(0.55))
                        .tracking(2)
                }

                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundStyle(Color(hex: "151515"))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                Text(hint)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(Color(hex: "151515").opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
    }
}
