//  StopBusRoutes.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct StopBusRoutes: Sendable, Hashable, Identifiable {

    public var id: String { route.id }
    public let route: BusRoutes
    public var stop: Stop?
    public var bus: Bus { route.bus }

    public init(route: BusRoutes, stop: Stop?) {
        self.route = route
        self.stop = stop
    }
}
