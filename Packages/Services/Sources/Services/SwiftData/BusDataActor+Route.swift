//  BusDataActor+Route.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation

public extension StoreDataActor {

    private var routeDescriptor: FetchDescriptor<BusRoutingInfoModel> { .init() }

    func route(busStopCode: String) throws -> BusRoutingInfo? {
        var descriptor = FetchDescriptor<BusRoutingInfoModel>(
            predicate: #Predicate {
                $0.busStopCode == busStopCode
            },
            sortBy: [.init(\.serviceNo)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.toSendable()
    }

    func routeAll() throws -> [BusRoutingInfo] {
        try context
            .fetch(routeDescriptor)
            .map { $0.toSendable() }
    }

    func routeAllCount() throws -> Int {
        try context.fetchCount(routeDescriptor)
    }

    func busServiceStops(
        serviceNo: String
    ) throws -> [BusRoutes] {
        let descriptor = FetchDescriptor<BusRoutingInfoModel>(
            predicate: #Predicate {
                $0.serviceNo == serviceNo
            },
            sortBy: [.init(\.stopSequence)]
        )
        return try context.fetch(descriptor).map { $0.toSendable() }.buildServiceRoutes()
    }

    func routes(
        for bus: Bus
    ) throws -> [BusRoutingInfo] {
        let serviceNo = bus.busNumber
        let direction = bus.direction.rawValue

        let descriptor = FetchDescriptor<BusRoutingInfoModel>(
            predicate: #Predicate {
                $0.serviceNo == serviceNo && $0.direction == direction
            },
            sortBy: [.init(\.stopSequence)]
        )
        return try context.fetch(descriptor).map { $0.toSendable() }
    }

    func busServiceStops(busStopCode: String) throws -> [BusRoutes] {
        let uniqueBusses = try Array(Set(busses(busStopCode: busStopCode)))
        return try uniqueBusses.compactMap { bus -> BusRoutes? in
            let routes = try routes(for: bus)
            guard routes.isEmpty == false else {
                return nil
            }
            return BusRoutes(
                busNumber: bus.busNumber,
                direction: bus.direction,
                stops: routes
            )
        }
    }

    func busses(
        busStopCode: String
    ) throws -> [Bus] {
        let descriptor = FetchDescriptor<BusRoutingInfoModel>(
            predicate: #Predicate {
                $0.busStopCode == busStopCode
            },
            sortBy: [.init(\.serviceNo)]
        )
        return
            try context
                .fetch(descriptor)
                .map { $0.toSendable() }
                .map { .init($0.serviceNo, $0.direction, busOperator: $0.operatorType) }
    }

    func save(routes: [BusRoutingInfo]) throws {
        let existingModels = try context.fetch(FetchDescriptor<BusRoutingInfoModel>())
        var indexedModels = Dictionary(
            uniqueKeysWithValues: existingModels.map { ($0.id, $0) }
        )
        for route in routes {
            if let model = indexedModels[route.id] {
                model.update(from: route)
            } else {
                let model = BusRoutingInfoModel(from: route)
                context.insert(model)
                indexedModels[route.id] = model
            }
        }
        try save()
    }
}
