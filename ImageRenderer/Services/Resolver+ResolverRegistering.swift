//
//  Resolver+ResolverRegistering.swift
//  HyperSketch
//
//  Created by Shawn Koh on 2/6/21.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { ContentViewModel() }
            .scope(.shared)
    }
}
