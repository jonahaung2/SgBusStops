//  BusDataActor+BusStop.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation
import CoreLocation

public extension StoreDataActor {

    func save(response: BusStopModel.Response) throws {
        let existingModels = try context.fetch(FetchDescriptor<BusStopModel>())
        var indexedModels = Dictionary(
            uniqueKeysWithValues: existingModels.map { ($0.busStopCode, $0) }
        )
        for busStop in response.value {
            if let model = indexedModels[busStop.busStopCode] {
                model.update(from: busStop)
            } else {
                let model = BusStopModel(from: busStop)
                context.insert(model)
                indexedModels[busStop.busStopCode] = model
            }
        }
        try save()
    }

    private var busStopDescriptor: FetchDescriptor<BusStopModel> { .init() }
    func busStop(for busStopCode: String) throws -> Stop? {
        try busStopModel(for: busStopCode)?.toSendable()
    }

    private func busStopModel(for code: String) throws -> BusStopModel? {
        var descriptor = FetchDescriptor<BusStopModel>(
            predicate: #Predicate {
                $0.busStopCode == code
            },
            sortBy: [.init(\.busStopCode)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func busStopAll() throws -> [Stop] {
        try context
            .fetch(busStopDescriptor)
            .map { $0.toSendable() }
    }

    func busStopAllCount() throws -> Int {
        try context.fetchCount(busStopDescriptor)
    }

    func search(_ searchText: String) -> [Stop] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            let descriptor = FetchDescriptor<BusStopModel>(sortBy: [.init(\.busStopCode)])
            guard let allStops = try? context.fetch(descriptor) else {
                return []
            }
            return allStops.map { $0.toSendable() }
        }
        let descriptor = FetchDescriptor<BusStopModel>(
            predicate: #Predicate {
                $0.roadName.localizedStandardContains(query)
                    || $0.desc.localizedStandardContains(query)
            },
            sortBy: [.init(\.busStopCode)]
        )
        guard let matchedStops = try? context.fetch(descriptor) else {
            return []
        }
        return matchedStops.map { $0.toSendable() }
    }
}
