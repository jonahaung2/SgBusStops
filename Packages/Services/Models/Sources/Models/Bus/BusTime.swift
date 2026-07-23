//  BusTime.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation

public struct BusTime: Codable, Hashable, Sendable {
    public let raw: String

    public init(raw: String) {
        self.raw = raw
    }

    public var date: Date? {
        guard raw.count == 4 else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: raw)
    }

    // Convert to "HH:mm"
    public var formatted: String {
        guard raw.count == 4 else { return "-" }
        let hours = raw.prefix(2)
        let minutes = raw.suffix(2)
        return "\(hours):\(minutes)"
    }
}
