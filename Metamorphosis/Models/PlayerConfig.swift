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
    static let centaur = PlayerConfig(
        assetPrefix: "Centaur",
        frameCount: 3,
        idleFrameIndex: 1,
        size: CGSize(width: 64, height: 85), // native sprite dimensions per README
        initialPosition: CGPoint(x: 80, y: 567.55),
        initialFacing: .down,
        speed: 140,
        zPosition: 2.5,
        frameDuration: 0.15 // matches the sheet's own 150ms preview delay
    )
}
