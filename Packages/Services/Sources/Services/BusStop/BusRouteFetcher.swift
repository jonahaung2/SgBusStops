//  BusRouteFetcher.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Client
import Models
import SwiftUI

public struct BusRouteFetcher: Sendable {
    private let repo: BusRoutesRepository = .init(networkClient: NetworkClient())

    public init() {}
    @discardableResult
    @concurrent
    public func all(force: Bool = false) async throws -> [BusRoutingInfo] {
        let localBusStops = try await SwiftDataStore.shared.store.routeAll()
        guard localBusStops.isEmpty || force else { return localBusStops }
        let routes = try await repo.fetchAll()
        try await SwiftDataStore.shared.store.save(routes: routes)
        return routes
    }

    public func hasSetupStore() async throws -> Bool {
        try await SwiftDataStore.shared.store.routeAllCount() > 0
    }

    @concurrent
    public func refreshAll() async throws -> [BusRoutingInfo] {
        let response = try await repo.fetchAll()
        try await SwiftDataStore.shared.store.save(routes: response)
        return try await all()
    }
}
