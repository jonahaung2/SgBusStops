//  FavouriteArrivalModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import SwiftData

@Model
public final class FavouriteArrivalModel {
    @Attribute(.unique) public var id: String
    public var busStopCode: String
    public var busServiceNumber: String
    public var date: Date

    public init(busStopCode: String, busServiceNumber: String) {
        id = Self.makeID(busStopCode: busStopCode, busServiceNumber: busServiceNumber)
        self.busStopCode = busStopCode
        self.busServiceNumber = busServiceNumber
        date = Date()
    }
}

public extension FavouriteArrivalModel {
    static func makeID(busStopCode: String, busServiceNumber: String) -> String {
        "\(busStopCode)_\(busServiceNumber)"
    }

    var sendable: FavouriteArrival {
        FavouriteArrival(
            id: id,
            busStopCode: busStopCode,
            busServiceNumber: busServiceNumber,
            date: date
        )
    }
}
