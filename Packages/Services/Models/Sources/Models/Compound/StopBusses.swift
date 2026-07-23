//  StopBusses.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct StopBusses: Sendable, Identifiable, Hashable {
    let stop: Stop
    let busses: [Bus]
    public var id: String { stop.busStopCode + busses.map(\.busNumber).joined() }
}
