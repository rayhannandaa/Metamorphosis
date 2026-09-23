//
//  InteractableObjectType.swift
//  Metamorphosis
//

import CoreGraphics
import SpriteKit

/// Identifies each interactable object in the game and defines its
/// dialogue depending on the character state (ASARYUNGamePhase) and time of day.
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

    var defaultSize: CGSize {
        switch self {
        case .bed: return CGSize(width: 90, height: 140)
        case .window: return CGSize(width: 95, height: 75)
        case .smartphone: return CGSize(width: 28, height: 42)
        case .photoAlbum: return CGSize(width: 36, height: 42)
        case .laptop: return CGSize(width: 46, height: 36)
        case .crochetBeanie: return CGSize(width: 32, height: 30)
        case .wardrobe: return CGSize(width: 85, height: 125)
        case .door: return CGSize(width: 55, height: 110)
        case .sofa: return CGSize(width: 120, height: 75)
        }
    }

    var defaultColor: SKColor {
        switch self {
        case .bed: return SKColor(red: 0.28, green: 0.38, blue: 0.65, alpha: 1.0)
        case .window: return SKColor(red: 0.35, green: 0.70, blue: 0.90, alpha: 1.0)
        case .smartphone: return SKColor(red: 0.25, green: 0.25, blue: 0.30, alpha: 1.0)
        case .photoAlbum: return SKColor(red: 0.76, green: 0.58, blue: 0.40, alpha: 1.0)
        case .laptop: return SKColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1.0)
        case .crochetBeanie: return SKColor(red: 0.85, green: 0.45, blue: 0.45, alpha: 1.0)
        case .wardrobe: return SKColor(red: 0.50, green: 0.34, blue: 0.24, alpha: 1.0)
        case .door: return SKColor(red: 0.38, green: 0.26, blue: 0.18, alpha: 1.0)
        case .sofa: return SKColor(red: 0.25, green: 0.50, blue: 0.45, alpha: 1.0)
        }
    }

    var defaultPosition: CGPoint {
        switch self {
        case .bed: return CGPoint(x: 95, y: 580)
        case .window: return CGPoint(x: 250, y: 720)
        case .smartphone: return CGPoint(x: 420, y: 80)
        case .photoAlbum: return CGPoint(x: 430, y: 310)
        case .laptop: return CGPoint(x: 385, y: 415)
        case .crochetBeanie: return CGPoint(x: 100, y: 75)
        case .wardrobe: return CGPoint(x: 415, y: 675)
        case .door: return CGPoint(x: 50, y: 360)
        case .sofa: return CGPoint(x: 110, y: 175)
        }
    }

    /// Resolves monologue text according to character phase and time of day (isDaytime).
    /// Reference: ASARYUNGameClock (isDaytime) & ASARYUNGamePhase (.worm, .pupa, .butterfly).
    ///
    /// Spreadsheet notes:
    /// - Larvae = .worm
    /// - Pupae = .pupa
    /// - Butterfly = .butterfly
    /// - Time: Disabled = Day (isDaytime == true)
    /// - Time: Enabled = Night (isDaytime == false)
    ///
    /// Bed is currently the only object whose monologue changes based on time of day.
    func monologue(for phase: ASARYUNGamePhase, isDaytime: Bool) -> String? {
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
