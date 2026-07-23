//  LocationAdapterProtocol.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import CoreLocation

public protocol LocationAdapterProtocol: AnyObject, Sendable {
    var delegate: CLLocationManagerDelegate? { get set }

    var authorizationStatus: CLAuthorizationStatus { get }
    var accuracyAuthorization: CLAccuracyAuthorization { get }
    var location: CLLocation? { get }

    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func requestTemporaryFullAccuracyAuthorization(
        purposeKey: String
    ) async throws

    func requestLocation()
    func setDesiredAccuracy(_ accuracy: CLLocationAccuracy)

    func startUpdatingLocation(
        with configuration: TrackingConfiguration
    )

    func stopUpdatingLocation()

    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()

    func startMonitoringRegion(_ region: CLRegion)
    func stopMonitoringRegion(_ region: CLRegion)
}

public final class CLLocationManagerAdapter:
    NSObject,
    LocationAdapterProtocol,
    @unchecked Sendable {
    private let manager: CLLocationManager

    override public init() {
        manager = CLLocationManager()
        super.init()
    }

    public weak var delegate: CLLocationManagerDelegate? {
        get { manager.delegate }
        set { manager.delegate = newValue }
    }

    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    public var accuracyAuthorization: CLAccuracyAuthorization {
        if #available(iOS 14.0, *) {
            manager.accuracyAuthorization
        } else {
            .fullAccuracy
        }
    }

    public var location: CLLocation? {
        manager.location
    }

    // MARK: Authorization

    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    public func requestTemporaryFullAccuracyAuthorization(
        purposeKey: String
    ) async throws {
        guard #available(iOS 14.0, *) else { return }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: purposeKey
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // MARK: One-Shot

    public func requestLocation() {
        manager.requestLocation()
    }

    public func setDesiredAccuracy(_ accuracy: CLLocationAccuracy) {
        manager.desiredAccuracy = accuracy
    }

    // MARK: Continuous

    public func startUpdatingLocation(
        with configuration: TrackingConfiguration
    ) {
        manager.desiredAccuracy = configuration.accuracy
        manager.distanceFilter = configuration.distanceFilter
        manager.activityType = configuration.activityType
        manager.pausesLocationUpdatesAutomatically = configuration.pausesAutomatically
        manager.allowsBackgroundLocationUpdates = configuration.allowsBackgroundUpdates

        if #available(iOS 11.0, *), #available(watchOS 4.0, *), #available(tvOS 11.0, *), #available(macOS 10.13, *) {
            #if os(iOS)
                // Only iOS exposes showsBackgroundLocationIndicator on CLLocationManager
                manager.showsBackgroundLocationIndicator = configuration.showsBackgroundLocationIndicator
            #endif
        }

        manager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // MARK: Significant Change

    public func startMonitoringSignificantLocationChanges() {
        manager.startMonitoringSignificantLocationChanges()
    }

    public func stopMonitoringSignificantLocationChanges() {
        manager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: Geo-Fencing

    public func startMonitoringRegion(_ region: CLRegion) {
        manager.startMonitoring(for: region)
    }

    public func stopMonitoringRegion(_ region: CLRegion) {
        manager.stopMonitoring(for: region)
    }
}

// MARK: - Optional support for background indicator on configurations

/// Adopt this protocol on your TrackingConfiguration type if you want to control the
/// background location indicator. If not adopted, the adapter will default to `false`.
public protocol _ShowsBackgroundIndicatorProviding {
    var showsBackgroundLocationIndicator: Bool { get }
}
