//  FavouriteArrival.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct FavouriteArrival: Sendable, Hashable, Identifiable {
    public let id: String
    public let busStopCode: String
    public let busServiceNumber: String
    public let date: Date

    public init(id: String, busStopCode: String, busServiceNumber: String, date: Date) {
        self.id = id
        self.busStopCode = busStopCode
        self.busServiceNumber = busServiceNumber
        self.date = date
    }
}
