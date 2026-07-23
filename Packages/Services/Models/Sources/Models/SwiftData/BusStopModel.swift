//  BusStopModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import SwiftData
import CoreLocation

@Model
public final class BusStopModel {

    @Attribute(.unique) public var busStopCode: String
    public var roadName: String
    public var desc: String
    public var latitude: Double
    public var longitude: Double

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
}

public extension BusStopModel {
    convenience init(from sendable: Stop) {
        self.init(
            busStopCode: sendable.busStopCode,
            roadName: sendable.roadName,
            desc: sendable.desc,
            latitude: sendable.latitude,
            longitude: sendable.longitude
        )
    }

    func toSendable() -> Stop {
        Stop(
            busStopCode: busStopCode,
            roadName: roadName,
            desc: desc,
            latitude: latitude,
            longitude: longitude
        )
    }

    func update(from item: Stop) {
        if roadName != item.roadName {
            roadName = item.roadName
        }
        if desc != item.desc {
            desc = item.desc
        }
        if latitude != item.latitude {
            latitude = item.latitude
        }
        if longitude != item.longitude {
            longitude = item.longitude
        }
    }
}

public extension BusStopModel {
    struct Response: Codable, Sendable {
        public let value: [Stop]

        public init(value: [Stop]) {
            self.value = value
        }
    }
}
