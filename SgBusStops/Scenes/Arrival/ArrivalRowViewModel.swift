//
//  ArrivalRowViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Models
import Services
import SwiftUI

@Observable
@MainActor
final class ArrivalRowViewModel: Identifiable {
    var id: String {
        item.id
    }

    var item: ArrivalItem

    var isFavourite: Bool = false
    var isUpdatingFavourite = false
    var favouriteErrorMessage: String?

    init(item: ArrivalItem) {
        self.item = item
        fetchFavourite()
    }

    func update(item: ArrivalItem) {
        self.item = item
        fetchFavourite()
    }

    func toggleFavourite() {
        guard !isUpdatingFavourite else {
            return
        }

        let serviceNo = item.arrival.serviceNo
        let shouldSave = !isFavourite
        isUpdatingFavourite = true
        favouriteErrorMessage = nil

        Task { @MainActor in
            defer {
                isUpdatingFavourite = false
            }

            do {
                if shouldSave {
                    try await FavouriteArrivalModel
                        .save(
                            .init(
                                busStopCode: item.busStop.busStopCode,
                                busServiceNumber: serviceNo,
                            ),
                        )
                } else {
                    try await FavouriteArrivalModel
                        .remove(busStopCode: item.busStop.busStopCode, busServiceNo: serviceNo)
                }
                fetchFavourite()
            } catch {
                favouriteErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
}

extension ArrivalRowViewModel {
    private func fetchFavourite() {
        let savedFavourite = FavouriteArrivalModel.fetch(
            busStopCode: item.busStop.busStopCode,
            busServiceNo: item.arrival
                .serviceNo,
        )
        isFavourite = savedFavourite != nil
    }
}
