//  BusStopFetcher.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Client
import Models
import SwiftUI

public struct BusStopFetcher: Sendable {
    private let repo: BusStopRepository = .init(networkClient: NetworkClient())

    public init() {}
    @concurrent
    public func all(force: Bool = false) async throws -> [Stop] {
        let localBusStops = try await SwiftDataStore.shared.store.busStopAll()
        guard localBusStops.isEmpty || force else { return localBusStops }
        let response = try await repo.fetchData(count: 0)
        try await SwiftDataStore.shared.store.save(response: response)
        return response.value
    }

    @concurrent
    public func refreshAll() async throws -> [Stop] {
        let response = try await repo.fetchData(count: 0)
        try await SwiftDataStore.shared.store.save(response: response)
        return try await all()
    }

    @concurrent
    public func fetchArrivalForBusService(busServiceNumber: String, busStopCode: String) async throws -> [BusArrival] {
        let busArrivalRepository = BusArrivalRepository()
        let arrival = try await busArrivalRepository.fetch(
            for: busStopCode,
            busServiceNumber: busServiceNumber
        )
        return arrival.services
    }
}
