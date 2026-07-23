//  BusStopRepository.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation
import CoreLocation

public protocol BusStopRepositoryProtocol: Sendable {
    func fetchData(count: Int) async throws -> BusStopModel.Response
}

public actor BusStopRepository: BusStopRepositoryProtocol {
    private let networkClient: NetworkClientProtocol

    /// LTA API page size limit
    private let pageSize = 500

    /// Max parallel requests
    private let maxConcurrentRequests = 1

    public init(
        networkClient: NetworkClientProtocol = NetworkClient(logger: NetworkLogger())
    ) {
        self.networkClient = networkClient
    }

    public func fetchData(count: Int) async throws -> BusStopModel.Response {
        let targetCount = count > 0 ? count : Int.max
        var allStops = [Stop]()

        var skip = 0
        var finished = false

        while !finished {
            try Task.checkCancellation()
            let batchStart = skip
            let results: [[Stop]] = try await withThrowingTaskGroup(
                of: [Stop].self
            ) { group in
                for i in 0 ..< maxConcurrentRequests {
                    let requestSkip = batchStart + (i * pageSize)
                    group.addTask { [networkClient] in
                        let request = BusStopAPI.BusStopsRequest(
                            top: self.pageSize,
                            skip: requestSkip
                        )
                        let response: BusStopModel.Response =
                            try await networkClient.performAndDecode(request)
                        return response.value
                    }
                }
                var pages = [[Stop]]()
                pages.reserveCapacity(self.maxConcurrentRequests)

                for try await page in group {
                    pages.append(page)
                }
                return pages
            }

            for page in results {
                if page.isEmpty {
                    finished = true
                    break
                }
                allStops.append(contentsOf: page)
                if allStops.count >= targetCount {
                    finished = true
                    break
                }
                if page.count < pageSize {
                    finished = true
                    break
                }
            }
            skip += pageSize * maxConcurrentRequests
        }
        return BusStopModel.Response(value: allStops)
    }
}
