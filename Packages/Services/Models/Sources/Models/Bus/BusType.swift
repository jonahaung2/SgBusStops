//  BusType.swift
//
//  Copyright © 2026 Aung Ko Min.
//

public enum BusType: String, Codable, Sendable {
    case singleDeck = "SD"
    case doubleDeck = "DD"
    case bendy = "BD"
}

extension BusType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .singleDeck:
            "Single"
        case .doubleDeck:
            "Double"
        case .bendy:
            "Bendy"
        }
    }
}
