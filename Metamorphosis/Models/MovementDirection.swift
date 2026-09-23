//
//  MovementDirection.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 22/09/26.
//



// Models/MovementDirection.swift
enum MovementDirection: CaseIterable {
    case up, down, left, right

    /// Matches the N/E/S/W naming used by the sprite sheet frames.
    var compassCode: String {
        switch self {
        case .up: return "N"
        case .down: return "S"
        case .left: return "W"
        case .right: return "E"
        }
    }
}
