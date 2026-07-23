//  BusArrivalRepository.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation

public protocol BusArrivalRepositoryProtocol {
    func fetch(for code: String) async throws -> BusArrivalAPI.BusArrivalListResponse
    func fetch(for code: String, busServiceNumber: String) async throws
        -> BusArrivalAPI.BusArrivalListResponse
}

public actor BusArrivalRepository: BusArrivalRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    public init(networkClient: NetworkClientProtocol = NetworkClient(logger: NetworkLogger())) {
        self.networkClient = networkClient
    }

    public func fetch(for busStopCode: String) async throws -> BusArrivalAPI.BusArrivalListResponse {
        let request = BusArrivalAPI.Request(busStopCode: busStopCode)
        return try await networkClient.performAndDecode(request)
    }

    public func fetch(for code: String, busServiceNumber: String) async throws
    -> BusArrivalAPI.BusArrivalListResponse {
        let request = BusArrivalAPI.Request(
            busStopCode: code,
            busServiceNumber: busServiceNumber
        )
        return try await networkClient.performAndDecode(request)
    }
}
