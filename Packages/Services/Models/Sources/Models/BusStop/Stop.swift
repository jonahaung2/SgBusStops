//  Stop.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation
import CoreLocation

public struct Stop: Codable, Sendable, Hashable {
    public let busStopCode: String
    public let roadName: String
    public let desc: String
    public let latitude: Double
    public var longitude: Double
    public var isArrivalFetching = true

    public init(
        busStopCode: String,
        roadName: String,
        desc: String,
        latitude: Double,
        longitude: Double
    ) {
        self.busStopCode = busStopCode
        self.roadName = roadName
        self.desc = desc
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(
        busStopCode: String,
        roadName: String,
        description: String,
        latitude: Double,
        longitude: Double
    ) {
        self.busStopCode = busStopCode
        self.roadName = roadName
        desc = description
        self.latitude = latitude
        self.longitude = longitude
    }

    enum CodingKeys: String, CodingKey {
        case busStopCode = "BusStopCode"
        case roadName = "RoadName"
        case desc = "Description"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
}

extension Stop: Identifiable {
    public var id: String {
        busStopCode
    }
}

public extension Stop {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        .init(latitude: latitude, longitude: longitude)
    }
}
