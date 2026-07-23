//  LocationAnalyticsProtocol.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import CoreLocation

public protocol LocationAnalyticsProtocol: AnyObject, Sendable {
    // Authorization
    func logAuthorizationRequested(requireAlways: Bool)
    func logAuthorizationChanged(
        status: CLAuthorizationStatus,
        accuracy: CLAccuracyAuthorization
    )

    /// Requests
    func logLocationRequestStarted(
        accuracy: CLLocationAccuracy,
        powerMode: Bool
    )

    func logLocationRequestCompleted(
        result: LocationResult,
        duration: TimeInterval
    )

    func logLocationRequestCancelled()

    func logLocationRequestFailed(
        error: LocationError
    )

    // Tracking
    func logTrackingStarted(configuration: TrackingConfiguration)
    func logTrackingStopped()

    func logSignificantChangeTriggered()

    /// State Machine
    func logStateTransition(
        from: MobilityState,
        to: MobilityState
    )

    /// Errors
    func logError(
        _ error: LocationError,
        context: [String: Any]
    )
}

public final class LocationAnalytics:
    LocationAnalyticsProtocol,
    @unchecked Sendable {
    private let lock: NSLock = .init()
    private let isProduction: Bool

    public init(isProduction: Bool = true) {
        self.isProduction = isProduction
    }
}

public extension LocationAnalytics {
    func logAuthorizationRequested(requireAlways: Bool) {
        log(event: "location_auth_requested", data: [
            "requireAlways": requireAlways
        ])
    }

    func logAuthorizationChanged(
        status: CLAuthorizationStatus,
        accuracy: CLAccuracyAuthorization
    ) {
        log(event: "location_auth_changed", data: [
            "status": status.rawValue,
            "accuracy": accuracy.rawValue
        ])
    }
}

public extension LocationAnalytics {
    func logLocationRequestStarted(
        accuracy: CLLocationAccuracy,
        powerMode: Bool
    ) {
        log(event: "location_request_started", data: [
            "accuracy": bucketAccuracy(accuracy),
            "lowPowerMode": powerMode
        ])
    }

    func logLocationRequestCompleted(
        result: LocationResult,
        duration: TimeInterval
    ) {
        log(event: "location_request_completed", data: [
            "accuracy": bucketAccuracy(result.horizontalAccuracy),
            "duration_ms": Int(duration * 1000),
            "source": result.source.rawValue
        ])
    }

    func logLocationRequestCancelled() {
        log(event: "location_request_cancelled", data: [:])
    }

    func logLocationRequestFailed(error: LocationError) {
        log(event: "location_request_failed", data: [
            "error": error.analyticsName
        ])
    }
}

public extension LocationAnalytics {
    func logTrackingStarted(configuration: TrackingConfiguration) {
        log(event: "tracking_started", data: [
            "accuracy": bucketAccuracy(configuration.accuracy),
            "distanceFilter": configuration.distanceFilter,
            "background": configuration.allowsBackgroundUpdates
        ])
    }

    func logTrackingStopped() {
        log(event: "tracking_stopped", data: [:])
    }

    func logSignificantChangeTriggered() {
        log(event: "significant_change_triggered", data: [:])
    }
}

public extension LocationAnalytics {
    func logStateTransition(
        from: MobilityState,
        to: MobilityState
    ) {
        log(event: "location_state_transition", data: [
            "from": String(describing: from),
            "to": String(describing: to)
        ])
    }
}

public extension LocationAnalytics {
    func logError(
        _ error: LocationError,
        context: [String: Any]
    ) {
        var data: [String: Any] = [
            "error": error.analyticsName
        ]
        data.merge(context) { $1 }

        log(event: "location_error", data: data)
    }
}

private extension LocationAnalytics {
    func log(event: String, data: [String: Any]) {
        lock.lock()
        defer { lock.unlock() }
        _ = event
        _ = data
        _ = isProduction
    }

    func bucketAccuracy(_ accuracy: CLLocationAccuracy) -> String {
        switch accuracy {
        case ..<20: "very_high"
        case ..<50: "high"
        case ..<100: "medium"
        default: "low"
        }
    }
}
