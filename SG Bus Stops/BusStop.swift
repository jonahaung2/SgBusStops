//
//  BusStop.swift
//  SG Bus Stops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Foundation

/// The API returns an object with a top-level key "value" containing an array of bus stops.
struct BusStopsEnvelope: Codable {
    let value: [BusStop]
}

/// Minimal model used by ContentView for display.
struct BusStop: Codable, Hashable, CustomStringConvertible {
    let busStopCode: String
    let roadName: String
    let descriptionText: String

    /// Map JSON keys to Swift properties.
    enum CodingKeys: String, CodingKey {
        case busStopCode = "BusStopCode"
        case roadName = "RoadName"
        case descriptionText = "Description"
    }

    var description: String {
        descriptionText
    }
}
