//  BusStore.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import CoreLocation

public final class BusStore: ViewModel {

    public var allBusStops: [Stop] = []
    public var routes: [BusRoutingInfo] = []

    @concurrent
    public func fetch(forceRefresh: Bool = false) async {
        await clearError()
        await loading(true)
        do {
            let allStops = try await fetchStops(forceRefresh: forceRefresh)
            let routes = try await fetchRoutes(forceRefresh: forceRefresh)
            Task { @MainActor in
                loading(false)
                self.allBusStops = allStops
                self.routes = routes
            }
        } catch {
            await loading(false)
            await showError(
                error,
                offlineTitle: "No Internet Connection",
                offlineDescription: "Connect to the internet to finish setting up the app and download the latest transport data.",
                fallbackTitle: "Setup Failed"
            )
        }
    }

    private let busStopFetcher: BusStopFetcher = .init()
    @concurrent
    private func fetchStops(forceRefresh: Bool) async throws -> [Stop] {
        try await busStopFetcher.all(force: forceRefresh)
    }

    private let routesFetcher: BusRouteFetcher = .init()
    @concurrent
    private func fetchRoutes(forceRefresh: Bool) async throws -> [BusRoutingInfo] {
        try await routesFetcher.all(force: forceRefresh)
    }

    public var isReady: Bool {
        !allBusStops.isEmpty && !routes.isEmpty
    }

    func near(by location: LocationResult, distance: Double) -> [Stop] {
        guard distance.isFinite, distance >= 0 else {
            return []
        }
        let origin = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let matched = allBusStops.compactMap { busStop -> (Stop, CLLocationDistance)? in
            let stopLocation = CLLocation(latitude: busStop.latitude, longitude: busStop.longitude)
            let stopDistance = origin.distance(from: stopLocation)
            guard stopDistance <= distance else {
                return nil
            }
            return (busStop, stopDistance)
        }

        return matched.sorted { $0.1 < $1.1 }.map(\.0)
    }
}

public extension BusStore {
    func busStop(for code: String) -> Stop? {
        allBusStops.first { $0.busStopCode.lowercased().contains(code.lowercased()) }
    }
}
