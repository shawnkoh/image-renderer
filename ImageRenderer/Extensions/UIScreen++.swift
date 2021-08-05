//
//  UIScreen++.swift
//  HyperSketch
//
//  Created by Shawn Koh on 10/6/21.
//

import UIKit

extension UIScreen {
    static let screenSize = UIScreen.main.bounds.size
    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
    static let canvasLength = screenHeight
    static let handPercentage: CGFloat = 0.12
    static let handHeight: CGFloat = handPercentage * screenHeight
}
