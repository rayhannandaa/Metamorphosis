//
//  ASARYUNPhysicsCategory.swift
//  ASARYUN
//
//  The base game has no physics categories of its own (movement is
//  purely position-based), so these bitmasks are free to define
//  without any risk of colliding with existing behavior.
//

enum ASARYUNPhysicsCategory {
    static let player: UInt32 = 0b1
    static let sunRay: UInt32 = 0b10
    static let food: UInt32 = 0b100
}
