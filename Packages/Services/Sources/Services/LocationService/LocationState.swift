//  LocationState.swift
//
//  Copyright © 2026 Aung Ko Min.
//

public enum MobilityState: Sendable, Equatable {
    case idle
    case authorizing
    case warmingUp
    case acquiring
    case activeTracking
    case significantChange
    case lowPowerPaused
    case failed(LocationError)
}

public enum RequestLifecycle: Sendable {
    case created
    case requestingHardware
    case awaitingFix
    case completed(LocationResult)
    case cancelled
    case failed(LocationError)
}
