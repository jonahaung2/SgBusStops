//  BusStopArrival.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct BusStopArrival: Sendable, Hashable {

    public var bus: Bus { .init(arrival.serviceNo, .none, busOperator: arrival.operatorCode) }
    public let busStopCode: String
    public let arrival: BusArrival

    public init(busStopCode: String, arrival: BusArrival) {
        self.busStopCode = busStopCode
        self.arrival = arrival
    }
}

extension BusStopArrival: Identifiable {
    public var id: String {
        busStopCode + arrival.serviceNo
    }
}
