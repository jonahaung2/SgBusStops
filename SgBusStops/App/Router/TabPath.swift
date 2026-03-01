//
//  TabPath.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Foundation

public enum TabPath: Hashable, CaseIterable, CustomStringConvertible {
    case nearBy, settings, busStops
    public var description: String {
        switch self {
        case .nearBy: "Near By Stops"
        case .settings: "Settings"
        case .busStops: "Bus Stops"
        }
    }

    public var systemName: String {
        switch self {
        case .nearBy: "signpost.right.and.left"
        case .busStops: "bus.doubledecker.fill"
        case .settings: "gearshape.arrow.trianglehead.2.clockwise.rotate.90"
        }
    }

    public var canSearch: Bool {
        self == .busStops
    }
}
