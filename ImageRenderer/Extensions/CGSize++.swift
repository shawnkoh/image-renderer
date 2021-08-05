//
//  CGSize++.swift
//  HyperSketch
//
//  Created by Shawn Koh on 7/7/21.
//

import CoreGraphics

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> CGSize {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
