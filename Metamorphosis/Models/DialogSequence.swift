struct DialogSequence {
    let lines: [String]
}

enum GameDialogCatalog {
    static let introduction = DialogSequence(lines: [
        "Is that… me? Why am I a larva?",
        "I need to find out what happened.",
        "Until then, I have to survive."
    ])

    static let butterflyTransformation = DialogSequence(lines: [
        "All this time, I was afraid of what I was becoming.",
        "But this body carried me through the light, the hunger, and the darkness.",
        "I may not be who I was… but I can accept who I am now.",
        "These wings are mine. It’s time to find my way out."
    ])

    static let windowEscape = DialogSequence(lines: [
        "The air is coming through the window.",
        "There’s nothing left for me in this room.",
        "It’s time to fly."
    ])
}
