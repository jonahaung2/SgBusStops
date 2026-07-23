//  BusDataActor+Bus.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation

public extension StoreDataActor {
    func busAll() throws -> [Bus] {
        try routeAll().buildServiceRoutes().map(\.bus)
    }

    func busServiceStopsAll() throws -> [BusRoutes] {
        let buses = try routeAll().buildServiceRoutes().map(\.bus)
        let items = try buses.map { try self.busServiceStops(serviceNo: $0.busNumber) }
        return items.flatMap(\.self)
    }
}
