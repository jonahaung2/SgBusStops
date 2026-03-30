//
//  BusArrivalAttributes.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 29/3/26.
//

import ActivityKit
import Foundation

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
