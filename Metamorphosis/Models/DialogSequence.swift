struct DialogSequence {
    let lines: [String]
}

enum GameDialogCatalog {
    static let introduction = DialogSequence(lines: [
        "Is that… me? Why am I a larva?",
        "I need to learn how to move in this body.",
        "Until then, I have to survive."
    ])

    static let butterflyTransformation = DialogSequence(lines: [
        "The cocoon is gone. I have wings now.",
        "I still don’t know why this happened, but I can finally leave this room.",
        "The window… that’s my way out."
    ])

    static let windowEscape = DialogSequence(lines: [
        "The air is coming through the window.",
        "There’s nothing left for me in this room.",
        "It’s time to fly."
    ])
}
