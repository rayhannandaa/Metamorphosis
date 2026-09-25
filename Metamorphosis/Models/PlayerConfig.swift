//
//  PlayerConfig.swift
//  Metamorphosis
//
//  Created by Ezekiel Walfred on 22/09/26.
//


// Models/PlayerConfig.swift
import CoreGraphics
import Foundation

struct PlayerConfig {
    let assetPrefix: String       // frames named "<prefix>_<N/E/S/W>_<0...frameCount-1>"
    let frameCount: Int           // walk frames per direction
    let idleFrameIndex: Int       // center frame doubles as idle
    let size: CGSize
    let initialPosition: CGPoint
    let initialFacing: MovementDirection
    let speed: CGFloat
    let zPosition: CGFloat
    let frameDuration: TimeInterval
}

extension PlayerConfig {
    // Replaced 'centaur' with the proper 'player' configuration
    static let player = PlayerConfig(
        assetPrefix: "Worm",
        frameCount: 2, // Worm only uses 2 frames
        idleFrameIndex: 0,
        size: CGSize(width: 64, height: 64),
        initialPosition: CGPoint(x: 80, y: 567.55),
        initialFacing: .down,
        speed: 140,
        zPosition: 2.5,
        frameDuration: 0.2
    )
}
