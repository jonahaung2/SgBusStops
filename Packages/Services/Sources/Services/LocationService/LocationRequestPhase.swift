//  LocationRequestPhase.swift
//
//  Copyright © 2026 Aung Ko Min.
//

public enum LocationRequestPhase: Sendable, Equatable {
    case created
    case checkingAuthorization
    case authorizationRequired
    case authorized
    case attachedToGroup
    case requestingHardware
    case awaitingFix
    case completed(LocationResult)
    case cancelled
    case failed(LocationError)
}
