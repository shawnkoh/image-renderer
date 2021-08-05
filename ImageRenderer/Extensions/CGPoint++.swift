//
//  CGPoint++.swift
//  HyperSketch
//
//  Created by Shawn Koh on 17/7/21.
//

import CoreGraphics

extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> CGPoint {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
