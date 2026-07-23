//  BusRoutes.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct BusRoutes: Sendable, Identifiable, Hashable {

    public let bus: Bus
    public let routes: [BusRoutingInfo]

    public init(
        busNumber: BusNumber,
        direction: BusDirection,
        stops: [BusRoutingInfo]
    ) {
        bus = .init(
            busNumber,
            direction,
            busOperator: stops.first?.operatorType ?? .unknown
        )
        routes = stops
    }

    public init(bus: Bus, stops: [BusRoutingInfo]) {
        self.bus = bus
        routes = stops
    }

    public var direction: BusDirection { bus.direction }
    public var busNumber: BusNumber { bus.busNumber }

    public var id: String { bus.id }
}

extension BusRoutes {
    public var stopCodes: [String] {
        routes.map(\.busStopCode)
    }

    /// Check if route contains a stop
    public func contains(stopCode: String) -> Bool {
        routes.contains { $0.busStopCode == stopCode }
    }

    /// Get index of a stop
    public func index(of stopCode: String) -> Int? {
        routes.firstIndex { $0.busStopCode == stopCode }
    }

    /// Get next stop
    public func nextStop(after stopCode: String) -> BusRoutingInfo? {
        guard let index = index(of: stopCode),
            index + 1 < routes.count
        else { return nil }

        return routes[index + 1]
    }

    /// Path between two stops (inclusive)
    public func path(from start: String, to end: String) -> [BusRoutingInfo] {
        guard
            let startIndex = index(of: start),
            let endIndex = index(of: end),
            startIndex <= endIndex
        else { return [] }

        return Array(routes[startIndex...endIndex])
    }

    /// Distance between two stops
    public func distance(from start: String, to end: String) -> Double? {
        guard
            let s = routes.first(where: { $0.busStopCode == start }),
            let e = routes.first(where: { $0.busStopCode == end })
        else { return nil }

        return e.distance - s.distance
    }

    /// Reverse route (useful for UI / debugging)
    public var reversedStops: [BusRoutingInfo] {
        routes.reversed()
    }
}
extension Sequence where Element == BusRoutes {
    public func sortedByNumericPrefix() -> [BusRoutes] {
        self.sorted(by: { (lhs: BusRoutes, rhs: BusRoutes) -> Bool in
            let lhsNo = lhs.busNumber.integerValue ?? Int.max
            let rhsNo = rhs.busNumber.integerValue ?? Int.max

            if lhsNo != rhsNo {
                return lhsNo < rhsNo
            }
            return lhs.busNumber.suffixPart.localizedStandardCompare(
                rhs.busNumber.suffixPart
            ) == .orderedAscending
        })
    }
}
extension Sequence where Element == Bus {

    public func sortedByNumericPrefix() -> [Bus] {
        self.sorted(by: { (lhs: Bus, rhs: Bus) -> Bool in
            let lhsNo = lhs.busNumber.integerValue ?? Int.max
            let rhsNo = rhs.busNumber.integerValue ?? Int.max

            if lhsNo != rhsNo {
                return lhsNo < rhsNo
            }

            return lhs.busNumber.suffixPart.localizedStandardCompare(
                rhs.busNumber.suffixPart
            ) == .orderedAscending
        })
    }
}
extension String {
    public var integerValue: Int? {
        let digits = filter(\.isNumber)
        return digits.isEmpty ? nil : Int(digits)
    }
    public var suffixPart: String {
        String(drop { $0.isNumber })
    }
}
