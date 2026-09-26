//
//  GamePhase.swift
//  Gameplay
//

/// The three life stages of the metamorphosis arc.
enum GamePhase: Equatable {
    case worm
    case pupa
    case butterfly

    var displayName: String {
        switch self {
        case .worm: return "Worm"
        case .pupa: return "Pupa"
        case .butterfly: return "Butterfly"
        }
    }
}
