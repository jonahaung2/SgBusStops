//  MobilityLocationEngine.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Foundation
import CoreLocation

public final actor MobilityLocationEngine {
    nonisolated let adapter: LocationAdapterProtocol
    private nonisolated let analytics: LocationAnalyticsProtocol?

    private var state: MobilityState = .idle
    private var lastProcessedLocation: CLLocation?
    private var trackingContinuation: AsyncStream<LocationResult>.Continuation?
    private var currentLifecycle: RequestLifecycle = .created
    private var singleRequestContinuation: CheckedContinuation<LocationResult, Error>?
    private var singleRequestTimeoutTask: Task<Void, Never>?
    private var singleRequestCancellationTask: Task<Void, Never>?
    private var currentGeofenceRegion: CLRegion?

    private let regionThrottleDistance: CLLocationDistance = 25
    private let geoFenceRadius: CLLocationDistance = 80
    private let delegateBridge: DelegateBridge

    public init(
        adapter: LocationAdapterProtocol,
        analytics: LocationAnalyticsProtocol? = LocationAnalytics(isProduction: true)
    ) {
        self.adapter = adapter
        self.analytics = analytics

        let delegateBridge = DelegateBridge()
        self.delegateBridge = delegateBridge

        delegateBridge.onLocation = { [weak self] location in
            Task { await self?.handleLocation(location) }
        }
        delegateBridge.onError = { [weak self] error in
            Task { await self?.handleError(error) }
        }
        delegateBridge.onAuthorization = { [weak self] status in
            Task { await self?.handleAuthorization(status) }
        }

        self.adapter.delegate = delegateBridge
    }

    deinit {
        singleRequestTimeoutTask?.cancel()
        singleRequestCancellationTask?.cancel()
    }

    public func requestWhenInUseAuthorization() {
        transition(to: .authorizing)
        adapter.requestWhenInUseAuthorization()
    }
}

private final class DelegateBridge: NSObject, CLLocationManagerDelegate {
    typealias LocationHandler = @Sendable (CLLocation) -> Void
    typealias ErrorHandler = @Sendable (Error) -> Void
    typealias AuthorizationHandler = @Sendable (CLAuthorizationStatus) -> Void

    var onLocation: LocationHandler?
    var onError: ErrorHandler?
    var onAuthorization: AuthorizationHandler?

    @objc(locationManager:didUpdateLocations:)
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocation?(location)
    }

    @objc(locationManager:didFailWithError:)
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }

    @objc(locationManagerDidChangeAuthorization:)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorization?(manager.authorizationStatus)
    }
}

public extension MobilityLocationEngine {
    func requestProximityLocation(
        token: LocationCancellationToken?
    ) async throws -> LocationResult {
        guard adapter.authorizationStatus != .denied else {
            throw LocationError.permissionDenied
        }
        guard adapter.authorizationStatus != .restricted else {
            throw LocationError.restricted
        }

        transition(to: .warmingUp)
        currentLifecycle = .requestingHardware

        _ = try await requestSingle(
            accuracy: adaptiveAccuracy(kCLLocationAccuracyHundredMeters),
            token: token
        )

        guard token?.isCancelled != true else {
            currentLifecycle = .cancelled
            throw CancellationError()
        }

        transition(to: .acquiring)

        let refined = try await requestSingle(
            accuracy: adaptiveAccuracy(kCLLocationAccuracyNearestTenMeters),
            token: token
        )

        currentLifecycle = .completed(refined)
        transition(to: .activeTracking)

        return refined
    }
}

private extension MobilityLocationEngine {
    func requestSingle(
        accuracy: CLLocationAccuracy,
        token: LocationCancellationToken?
    ) async throws -> LocationResult {
        currentLifecycle = .awaitingFix

        if token?.isCancelled == true {
            currentLifecycle = .cancelled
            throw CancellationError()
        }

        adapter.setDesiredAccuracy(accuracy)

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LocationResult, Error>) in
                singleRequestTimeoutTask?.cancel()
                singleRequestCancellationTask?.cancel()
                singleRequestTimeoutTask = nil
                singleRequestCancellationTask = nil
                singleRequestContinuation = continuation

                singleRequestTimeoutTask = Task { [weak self] in
                    try? await Task.sleep(for: .seconds(8))
                    await self?.failSingleRequestIfNeeded(with: LocationError.timeout)
                }

                if let token {
                    singleRequestCancellationTask = Task { [weak self] in
                        while !Task.isCancelled {
                            if token.isCancelled {
                                await self?.failSingleRequestIfNeeded(with: LocationError.cancelled)
                                return
                            }
                            try? await Task.sleep(for: .milliseconds(150))
                        }
                    }
                }

                adapter.startUpdatingLocation(
                    with: TrackingConfiguration(
                        accuracy: accuracy,
                        distanceFilter: kCLDistanceFilterNone,
                        activityType: .other,
                        allowsBackgroundUpdates: false,
                        pausesAutomatically: true,
                        showsBackgroundIndicator: false
                    )
                )
            }
        } onCancel: {
            Task { [weak self] in
                await self?.failSingleRequestIfNeeded(with: CancellationError())
            }
        }
    }

    func succeedSingleRequestIfNeeded(with location: CLLocation) {
        guard let continuation = singleRequestContinuation else { return }
        adapter.stopUpdatingLocation()
        singleRequestTimeoutTask?.cancel()
        singleRequestCancellationTask?.cancel()
        singleRequestTimeoutTask = nil
        singleRequestCancellationTask = nil
        singleRequestContinuation = nil
        continuation.resume(returning: LocationResult(location: location, source: .gps))
    }

    func failSingleRequestIfNeeded(with error: Error) {
        guard let continuation = singleRequestContinuation else { return }
        adapter.stopUpdatingLocation()
        singleRequestTimeoutTask?.cancel()
        singleRequestCancellationTask?.cancel()
        singleRequestTimeoutTask = nil
        singleRequestCancellationTask = nil
        singleRequestContinuation = nil
        continuation.resume(throwing: error)
    }
}

public extension MobilityLocationEngine {
    func lastKnownLocation() -> LocationResult? {
        guard let location = adapter.location else {
            return nil
        }
        return LocationResult(location: location, source: .gps)
    }

    func startHybridTracking() -> AsyncStream<LocationResult> {
        transition(to: .activeTracking)
        trackingContinuation?.finish()
        adapter.stopMonitoringSignificantLocationChanges()

        return AsyncStream { continuation in
            trackingContinuation = continuation
            adapter.startUpdatingLocation(with: TrackingConfiguration.standard)

            continuation.onTermination = { [weak self] _ in
                Task { await self?.stopTracking() }
            }
        }
    }

    func moveToBackgroundMode() {
        adapter.stopUpdatingLocation()
        adapter.startMonitoringSignificantLocationChanges()
        transition(to: .significantChange)
    }

    func stopTracking() {
        adapter.stopUpdatingLocation()
        adapter.stopMonitoringSignificantLocationChanges()
        trackingContinuation?.finish()
        trackingContinuation = nil
        if let currentGeofenceRegion {
            adapter.stopMonitoringRegion(currentGeofenceRegion)
            self.currentGeofenceRegion = nil
        }
        transition(to: .idle)
    }
}

private extension MobilityLocationEngine {
    func handleLocation(_ location: CLLocation) {
        guard location.horizontalAccuracy >= 0 else { return }
        succeedSingleRequestIfNeeded(with: location)

        guard shouldProcess(location) else { return }

        lastProcessedLocation = location

        let result = LocationResult(location: location, source: .gps)
        trackingContinuation?.yield(result)
        configureGeoFence(for: location)
    }

    func shouldProcess(_ new: CLLocation) -> Bool {
        guard let last = lastProcessedLocation else { return true }
        return new.distance(from: last) > regionThrottleDistance
    }
}

private extension MobilityLocationEngine {
    func configureGeoFence(for location: CLLocation) {
        let radius = max(25, geoFenceRadius)
        let region = CLCircularRegion(
            center: location.coordinate,
            radius: radius,
            identifier: UUID().uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false

        if let currentGeofenceRegion {
            adapter.stopMonitoringRegion(currentGeofenceRegion)
        }
        currentGeofenceRegion = region
        adapter.startMonitoringRegion(region)
    }
}

private extension MobilityLocationEngine {
    func adaptiveAccuracy(_ requested: CLLocationAccuracy) -> CLLocationAccuracy {
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            transition(to: .lowPowerPaused)
            return max(requested, kCLLocationAccuracyHundredMeters)
        }
        return requested
    }
}

private extension MobilityLocationEngine {
    func transition(to newState: MobilityState) {
        let old = state
        guard old != newState else { return }
        state = newState
        analytics?.logStateTransition(from: old, to: newState)
    }
}

private extension MobilityLocationEngine {
    func handleError(_ error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        let mapped = LocationError.map(from: error)
        failSingleRequestIfNeeded(with: mapped)
        currentLifecycle = .failed(mapped)
        transition(to: .failed(mapped))
        analytics?.logError(mapped, context: ["underlyingError": String(describing: error)])
    }

    func handleAuthorization(_ status: CLAuthorizationStatus) {
        if status == .denied {
            failSingleRequestIfNeeded(with: LocationError.permissionDenied)
            transition(to: .failed(.permissionDenied))
            return
        }
        if status == .restricted {
            failSingleRequestIfNeeded(with: LocationError.restricted)
            transition(to: .failed(.restricted))
            return
        }
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if state == .authorizing {
                transition(to: .idle)
            }
        }
    }
}

private extension TrackingConfiguration {
    static var standard: TrackingConfiguration {
        TrackingConfiguration(
            accuracy: kCLLocationAccuracyBest,
            distanceFilter: 10,
            activityType: .other,
            allowsBackgroundUpdates: true,
            pausesAutomatically: true,
            showsBackgroundIndicator: true
        )
    }
}
