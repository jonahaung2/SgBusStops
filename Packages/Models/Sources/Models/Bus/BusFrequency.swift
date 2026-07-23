//  BusFrequency.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct BusFrequency: Codable, Sendable, Hashable {
    public let minMinutes: Int
    public let maxMinutes: Int

    public init(minMinutes: Int, maxMinutes: Int) {
        self.minMinutes = minMinutes
        self.maxMinutes = maxMinutes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        let parts = raw.split(separator: "-").compactMap { Int($0) }

        if parts.count == 2 {
            minMinutes = parts[0]
            maxMinutes = parts[1]
        } else if parts.count == 1 {
            minMinutes = parts[0]
            maxMinutes = parts[0]
        } else {
            minMinutes = 0
            maxMinutes = 0
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(minMinutes)-\(maxMinutes)")
    }
}
