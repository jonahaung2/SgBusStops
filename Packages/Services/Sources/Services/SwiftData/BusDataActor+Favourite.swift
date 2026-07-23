//  BusDataActor+Favourite.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftData
import Foundation

public extension StoreDataActor {

    func favouriteAll() -> [FavouriteArrival] {
        let descriptor = FetchDescriptor<FavouriteArrivalModel>(
            sortBy: [
                SortDescriptor(\FavouriteArrivalModel.date, order: .reverse)
            ]
        )
        return ((try? context.fetch(descriptor)) ?? []).compactMap(\.sendable)
    }

    func favouriteModel(busStopCode: String, busServiceNo: String)
        -> FavouriteArrivalModel?
    {
        var descriptor = FetchDescriptor<FavouriteArrivalModel>(
            predicate: #Predicate<FavouriteArrivalModel> {
                $0.busStopCode == busStopCode && $0.busServiceNumber == busServiceNo
            },
            sortBy: [
                SortDescriptor(\FavouriteArrivalModel.date, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func favourite(busStopCode: String, busServiceNo: String) async -> FavouriteArrival? {
        favouriteModel(busStopCode: busStopCode, busServiceNo: busServiceNo)?.sendable
    }

    func save(_ model: FavouriteArrivalModel) async throws {
        guard favouriteModel(
            busStopCode: model.busStopCode,
            busServiceNo: model.busServiceNumber
        ) == nil else {
            return
        }
        context.insert(model)
        try save()
    }

    func removeFavourite(busStopCode: String, busServiceNo: String) async throws {
        guard let model = favouriteModel(busStopCode: busStopCode, busServiceNo: busServiceNo) else {
            return
        }
        context.delete(model)
        if context.hasChanges {
            try context.save()
        }
    }

    func removeFavourite(sendable: FavouriteArrival) async throws {
        try await removeFavourite(
            busStopCode: sendable.busStopCode,
            busServiceNo: sendable.busServiceNumber
        )
    }

    func reorderFavourites(ids: [String]) throws {
        guard !ids.isEmpty else {
            return
        }
        let anchorDate = Date()
        for (index, id) in ids.enumerated() {
            var descriptor = FetchDescriptor<FavouriteArrivalModel>(
                predicate: #Predicate<FavouriteArrivalModel> {
                    $0.id == id
                },
                sortBy: [
                    SortDescriptor(\FavouriteArrivalModel.date, order: .reverse)
                ]
            )
            descriptor.fetchLimit = 1
            guard let model = try context.fetch(descriptor).first else {
                continue
            }
            model.date = anchorDate.addingTimeInterval(TimeInterval(-index))
        }
        if context.hasChanges {
            try context.save()
        }
    }
}

public extension FavouriteArrivalModel {
    @MainActor
    static func fetch(busStopCode: String, busServiceNo: String) -> FavouriteArrivalModel? {
        let context = SwiftDataStore.shared.appContainer.modelContainer.mainContext
        var descriptor = FetchDescriptor<FavouriteArrivalModel>(
            predicate: #Predicate<FavouriteArrivalModel> {
                $0.busStopCode == busStopCode && $0.busServiceNumber == busServiceNo
            },
            sortBy: [
                SortDescriptor(\FavouriteArrivalModel.date, order: .reverse)
            ]
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }
}

public extension FavouriteArrival {
    func busStop() async -> Stop? {
        try? await SwiftDataStore.shared.store.busStop(for: busStopCode)
    }
}
