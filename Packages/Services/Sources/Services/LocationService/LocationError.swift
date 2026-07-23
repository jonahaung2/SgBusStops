//  LocationError.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import CoreLocation

public enum LocationError: Error, Sendable, Equatable, LocalizedError {
    case permissionDenied
    case restricted
    case reducedAccuracy
    case timeout
    case locationServicesDisabled
    case cancelled
    case hardwareFailure
    case networkFailure
    case unknown
    case underlying(domain: String, code: Int)
    case requestInProgress

    public var analyticsName: String {
        switch self {
        case .permissionDenied: "permission_denied"
        case .restricted: "restricted"
        case .reducedAccuracy: "reduced_accuracy"
        case .timeout: "timeout"
        case .locationServicesDisabled: "services_disabled"
        case .cancelled: "cancelled"
        case .hardwareFailure: "hardware_failure"
        case .networkFailure: "network_failure"
        case .unknown: "unknown"
        case .underlying: "underlying_error"
        case .requestInProgress: "request_in_progress"
        }
    }

    public var errorDescription: String? {
        switch self {
        case .permissionDenied: "Location permission denied."
        case .restricted: "Location access is restricted."
        case .reducedAccuracy: "Location accuracy is reduced."
        case .timeout: "Location request timed out."
        case .locationServicesDisabled: "Location services are disabled."
        case .cancelled: "Location request was cancelled."
        case .hardwareFailure: "Unable to determine location right now."
        case .networkFailure: "A network error occurred while determining location."
        case .unknown: "An unknown location error occurred."
        case let .underlying(domain, code): "Location error (\(domain): \(code))."
        case .requestInProgress: "A location request is already in progress."
        }
    }
}

extension LocationError {
    static func map(from error: Error) -> LocationError {
        guard let clError = error as? CLError else {
            let ns = error as NSError
            return .underlying(domain: ns.domain, code: ns.code)
        }

        switch clError.code {
        case .denied: return .permissionDenied
        case .network: return .networkFailure
        case .locationUnknown: return .hardwareFailure
        default:
            let ns = clError as NSError
            return .underlying(domain: ns.domain, code: ns.code)
        }
    }
}
