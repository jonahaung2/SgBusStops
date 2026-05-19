//  BusArrivalAttributes.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation
import ActivityKit

nonisolated struct BusArrivalAttributes: ActivityAttributes, Sendable {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        var busNumber: String
        var busStopCode: String
        var stopName: String
        var arrivalTime: Date

        var trackingID: String {
            "\(busStopCode)-\(busNumber)"
        }
    }

    var id: String
}
