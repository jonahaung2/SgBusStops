//  BusLoad.swift
//
//  Copyright © 2026 Aung Ko Min.
//

public enum BusLoad: String, Codable, Sendable, CustomStringConvertible {
    public var description: String {
        switch self {
        case .seatsAvailable:
            "Seats Available"
        case .standingAvailable:
            "Standing Available"
        case .limitedStanding:
            "Limited Standing"
        }
    }

    case seatsAvailable = "SEA"
    case standingAvailable = "SDA"
    case limitedStanding = "LSD"
}
