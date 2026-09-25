//
//  InteractableObjectType.swift
//  Metamorphosis
//

import CoreGraphics

/// Identifies each interactable object in the game and defines its
/// dialogue depending on the character state (GamePhase) and time of day.
enum InteractableObjectType: String, CaseIterable, Identifiable {
    case bed
    case window
    case smartphone
    case photoAlbum
    case laptop
    case crochetBeanie
    case wardrobe
    case door
    case sofa

    var id: String { rawValue }

    /// The name assigned to the real room sprite by RoomWorldController.
    var roomNodeName: String {
        switch self {
        case .bed: return "Bed"
        case .window: return "Window"
        case .smartphone: return "Phone"
        case .photoAlbum: return "Photo"
        case .laptop: return "Laptop"
        case .crochetBeanie: return "Beanie"
        case .wardrobe: return "Wardrobe"
        case .door: return "Door"
        case .sofa: return "Sofa"
        }
    }

    /// Distance outside the sprite's edge where interaction becomes available.
    var interactionMargin: CGFloat {
        switch self {
        case .window:
            return 35
        case .photoAlbum:
            return 60
        default:
            return 25
        }
    }

    var displayName: String {
        switch self {
        case .bed: return "Bed"
        case .window: return "Window"
        case .smartphone: return "Smartphone"
        case .photoAlbum: return "Photo Album"
        case .laptop: return "Laptop"
        case .crochetBeanie: return "Crochet Beanie"
        case .wardrobe: return "Wardrobe"
        case .door: return "Door"
        case .sofa: return "Sofa"
        }
    }

    /// Resolves monologue text according to character phase and time of day (isDaytime).
    /// Reference: GameClock (isDaytime) & GamePhase (.worm, .pupa, .butterfly).
    ///
    /// Spreadsheet notes:
    /// - Larvae = .worm
    /// - Pupae = .pupa
    /// - Butterfly = .butterfly
    /// - Time: Disabled = Day (isDaytime == true)
    /// - Time: Enabled = Night (isDaytime == false)
    ///
    /// Bed is currently the only object whose monologue changes based on time of day.
    func monologue(for phase: GamePhase, isDaytime: Bool) -> String? {
        switch self {
        case .bed:
            switch phase {
            case .worm:
                return isDaytime
                    ? "Maybe I’ll sleep later when I’m tired..."
                    : "I’m too tired, need to go sleep..."
            case .pupa:
                return isDaytime
                    ? "I can't move but I feel awake..."
                    : "It's warm here, I'm starting to feel sleepy..."
            case .butterfly:
                return "I can just fly away and leave this room!"
            }

        case .window:
            switch phase {
            case .worm:
                return "This room is comfortable, protected from outside world..."
            case .pupa:
                return nil
            case .butterfly:
                return "Let's go fly away and feel the sunlight outside..."
            }

        case .smartphone:
            switch phase {
            case .worm:
                return "7 missed call from my friend. Are they inviting me to hangout?"
            case .pupa:
                return nil
            case .butterfly:
                return "7 missed call from my friend. Are they inviting me to hangout?"
            }

        case .photoAlbum:
            switch phase {
            case .worm:
                return "Photo from my university graduation. I look so young here..."
            case .pupa:
                return nil
            case .butterfly:
                return "Photo from my university graduation. I look so young here..."
            }

        case .laptop:
            switch phase {
            case .worm:
                return "Email from my boss is piling up. Workplace is still as busy as ever..."
            case .pupa:
                return nil
            case .butterfly:
                return "Email from my boss is piling up. Workplace is still as busy as ever..."
            }

        case .crochetBeanie:
            switch phase {
            case .worm:
                return "Gift from my girlfriend for our first year anniversary. I miss her..."
            case .pupa:
                return nil
            case .butterfly:
                return "Gift from my girlfriend for our first year anniversary. I miss her..."
            }

        case .wardrobe:
            switch phase {
            case .worm:
                return "All my clothes are boring. I wish I could have just worn my favorite band's shirt..."
            case .pupa:
                return nil
            case .butterfly:
                return "All my clothes are boring. I wish I could have just worn my favorite band's shirt..."
            }

        case .door:
            switch phase {
            case .worm:
                return "It's locked... I don't want to go out and surprise my family with my sudden appearance anyway..."
            case .pupa:
                return nil
            case .butterfly:
                return "I can just leave this room right now through the window..."
            }

        case .sofa:
            switch phase {
            case .worm:
                return "This is strange, below this sofa is dark and cold but I feel comfortable..."
            case .pupa:
                return nil
            case .butterfly:
                return "I don't feel comfortable here anymore, I want to feel the sunlight..."
            }
        }
    }
}
