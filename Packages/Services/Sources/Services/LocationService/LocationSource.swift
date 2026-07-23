//  LocationSource.swift
//
//  Copyright © 2026 Aung Ko Min.
//

public enum LocationSource: String, Sendable {
    case gps
    case cache
    case significantChange
    case geofence
    case mock
}
