//  BusRoutesRepository.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import Foundation

public protocol BusRoutesRepositoryProtocol {}

public actor BusRoutesRepository: BusRoutesRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let pageSize = 500
    private let maxConcurrentRequests = 1

    public init(networkClient: NetworkClientProtocol = NetworkClient(logger: NetworkLogger())) {
        self.networkClient = networkClient
    }

    @concurrent
    public func fetchAll() async throws -> [BusRoutingInfo] {
        var allRoutes = [BusRoutingInfo]()
        var skip = 0
        var finished = false

        while !finished {
            try Task.checkCancellation()
            let batchStart = skip
            let results: [[BusRoutingInfo]] = try await withThrowingTaskGroup(
                of: [BusRoutingInfo].self
            ) { group in
                for i in 0 ..< maxConcurrentRequests {
                    let requestSkip = batchStart + (i * pageSize)
                    group.addTask { [networkClient] in
                        let request = BusRouteAPI.Request(
                            top: self.pageSize,
                            skip: requestSkip
                        )
                        let response: BusRoutingInfo.Response =
                            try await networkClient.performAndDecode(request)
                        return response.value
                    }
                }

                var pages = [[BusRoutingInfo]]()
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
                allRoutes.append(contentsOf: page)
                if page.count < pageSize {
                    finished = true
                    break
                }
            }
            skip += pageSize * maxConcurrentRequests
        }

        return allRoutes
    }

    public func route(for serviceNo: String, direction: BusDirection) async throws
        -> BusRoutes?
    {
        let allRoutes = try await fetchAll()
        let build = allRoutes.buildServiceRoutes()

        return build.route(busService: serviceNo, direction: direction.rawValue)
    }

    public func remaining(serviceNo: String, direction: BusDirection, after busStopCode: String)
        async throws -> [BusRoutingInfo]
    {
        try await route(for: serviceNo, direction: direction)?.remainingStops(after: busStopCode)
            ?? []
    }

    public func remaining(serviceNo: String, direction: BusDirection, including busStopCode: String)
        async throws -> [BusRoutingInfo]
    {
        try await route(for: serviceNo, direction: direction)?.remainingStops(
            including: busStopCode
        ) ?? []
    }
}

public extension [BusRoutingInfo] {

    private func groupedByService() -> [String: [Int: [BusRoutingInfo]]] {
        Dictionary(grouping: self) { $0.serviceNo }
            .mapValues { routes in
                Dictionary(grouping: routes) { $0.direction.rawValue }
                    .mapValues { $0.sorted { $0.stopSequence < $1.stopSequence } }
            }
    }

    func busRoutes() -> [BusRoutes] {
        let grouped = groupedByService()
        var values = [BusRoutes]()
        for (key, dirValues) in grouped {
            for (dir, routes) in dirValues {
                let direction = BusDirection(rawValue: dir) ?? .inbound
                let op = routes.first?.operatorType ?? .unknown
                let bus = Bus(key, direction, busOperator: op)
                values.append(.init(bus: bus, stops: routes))
            }
        }
        return values
    }

    /// Flatten into structured route objects
    func buildServiceRoutes() -> [BusRoutes] {
        groupedByService()
            .flatMap { serviceNo, directions in
                directions.map { direction, stops in
                    BusRoutes(
                        busNumber: serviceNo,
                        direction: BusDirection(rawValue: direction) ?? .none,
                        stops: stops
                    )
                }
            }
    }
}

public extension [BusRoutes] {

    /// StopCode → [Routes]
    func indexByStop() -> [String: [BusRoutes]] {
        var result = [String: [BusRoutes]]()

        for route in self {
            for stop in route.routes {
                result[stop.busStopCode, default: []].append(route)
            }
        }

        return result
    }

    /// Get route by service + direction
    func route(busService: BusNumber, direction: Int) -> BusRoutes? {
        first {
            $0.busNumber == busService && $0.direction.rawValue == direction
        }
    }

    /// Find all routes that pass BOTH stops (basic trip planner)
    func routes(from start: String, to end: String) -> [BusRoutes] {
        filter {
            $0.contains(stopCode: start) && $0.contains(stopCode: end)
        }
    }
}

extension BusRoutes {

    /// Remaining stops AFTER a given stop (excluding current)
    func remainingStops(after stopCode: String) -> [BusRoutingInfo] {
        guard let index = routes.firstIndex(where: { $0.busStopCode == stopCode }),
              index + 1 < routes.count else { return [] }

        return Array(routes[(index + 1)...])
    }

    /// Remaining stops INCLUDING current stop
    func remainingStops(including stopCode: String) -> [BusRoutingInfo] {
        guard let index = routes.firstIndex(where: { $0.busStopCode == stopCode }) else { return [] }

        return Array(routes[index...])
    }
}

/*
 let routes = apiRoutes.buildServiceRoutes()

 // Get specific route
 let bus107 = routes.route(serviceNo: "107", direction: 1)

 // Next stop
 let next = bus107?.nextStop(after: "01219")

 // Path
 let path = bus107?.path(from: "01219", to: "02049")

 // Distance
 let distance = bus107?.distance(from: "01219", to: "02049")

 // Reverse index
 let stopIndex = routes.indexByStop()
 let busesAtStop = stopIndex["01219"]
 */
