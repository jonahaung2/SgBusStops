//  LocationService.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI

@MainActor
@Observable
public final class LocationService {
    public var location: LocationResult?
    public var address: String?
    public var lastError: LocationError?
    public var isRequestingLocation = false

    private let locationEngine: MobilityLocationEngine
    private let geocoder: SgGeoCoder = .init()
    private var token: LocationCancellationToken?

    public init() {
        let adaptor = CLLocationManagerAdapter()
        locationEngine = .init(adapter: adaptor)
    }

    public func startLocation() async {
        guard !isRequestingLocation else {
            return
        }

        isRequestingLocation = true
        defer { isRequestingLocation = false }
        lastError = nil

        let requestToken = LocationCancellationToken()
        token?.cancel()
        token = requestToken

        do {
            let resolved = try await requestLocationWithTimeoutRecovery(token: requestToken)
            try await applyResolvedLocation(resolved)
            return
        } catch let error as LocationError {
            lastError = error
        } catch {
            lastError = .unknown
        }

        if let fallback = await locationEngine.lastKnownLocation() {
            do {
                try await applyResolvedLocation(fallback)
                lastError = nil
            } catch {
                if lastError == nil {
                    lastError = .unknown
                }
            }
        }
    }
}

public extension EnvironmentValues {
    @Entry var currentLocation: LocationResult = .init(
        location: .init(),
        source: .cache
    )
}

private extension LocationService {
    func requestLocationWithTimeoutRecovery(token: LocationCancellationToken) async throws -> LocationResult {
        do {
            return try await locationEngine.requestProximityLocation(token: token)
        } catch LocationError.timeout {
            try await Task.sleep(for: .milliseconds(600))
            return try await locationEngine.requestProximityLocation(token: token)
        }
    }

    func applyResolvedLocation(_ location: LocationResult) async throws {
        self.location = location
        address = try await geocoder.createLocationInfo(from: location.clLocation)
    }
}
