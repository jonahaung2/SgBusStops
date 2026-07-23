//  TabPath.swift
//
//  Copyright © 2026 Aung Ko Min.
//

public enum TabPath: String, Hashable, CaseIterable, Codable, Sendable {
    case nearBy
    case saved
    case settings
    case busStops
}

extension TabPath: Identifiable {
    public var id: Self {
        self
    }
}

extension TabPath: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nearBy: "Near By Stops"
        case .settings: "Settings"
        case .busStops: "Bus Stops"
        case .saved:
            "Saved Arrivals"
        }
    }
}

public extension TabPath {
    var systemName: String {
        switch self {
        case .nearBy: "location"
        case .busStops: "magnifyingglass"
        case .settings: "shield.pattern.checkered"
        case .saved:
            "star.fill"
        }
    }

    var canSearch: Bool {
        self == .busStops
    }
}
