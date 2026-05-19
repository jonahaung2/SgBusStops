//  FavouriteArrivalViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

@Observable
final class FavouriteArrivalViewModel: ViewModel {

    var items: [ArrivalRowViewModel] = []
    var favourites: [FavouriteArrival] = []
    private let fetcher: BusStopFetcher = .init()
}

extension FavouriteArrivalViewModel {
    func item(for favourite: FavouriteArrival) -> ArrivalRowViewModel? {
        items.first {
            $0.arrival.busStopCode == favourite.busStopCode
                && $0.arrival.arrival.serviceNo == favourite.busServiceNumber
        }
    }

    func task() async {
        loading(true)

        clearError()
        do {
            let favourites = try await SwiftDataStore.shared.store.favouriteAll()

            if favourites.isEmpty {
                loading(false)
                self.favourites = []
                items = []
                showError(
                    .init(
                        "star.slash",
                        title: "No Saved Arrivals",
                        description:
                        "You haven’t saved any favorite arrivals. Add one by tapping the star icon at your preferred bus stop."
                    )
                )
                return
            }

            let items = try await AsyncOrderedStream.mapOrdered(inputs: favourites) { favourite in
                let arrival = try await self.fetcher
                    .fetchArrivalForBusService(
                        busServiceNumber: favourite.busServiceNumber,
                        busStopCode: favourite.busStopCode
                    )
                return await MainActor.run {
                    arrival
                        .map { BusStopArrival(busStopCode: favourite.busStopCode, arrival: $0) }
                }
            }
            let flattened = items.flatMap(\.self)
            loading(false)
            let existing = Dictionary(
                uniqueKeysWithValues: self.items.map { ($0.id, $0) }
            )
            self.items = flattened.map { item in
                if let model = existing[item.id] {
                    model.update(item: item)
                    return model
                }
                return .init(item: item)
            }
            self.favourites = favourites
            clearError()
        } catch {
            showError(
                error,
                offlineTitle: "Live Arrivals Unavailable",
                offlineDescription: "You're offline. Your saved bus stops are still available, but live arrival timings need an internet connection.",
                fallbackTitle: "Unable to Load Arrivals",
                fallbackImageName: "star.slash"
            )
        }
    }

    func onDelete(_ index: Int) {
        Task {
            let item = favourites[index]
            do {
                try await SwiftDataStore.shared.store
                    .removeFavourite(
                        busStopCode: item.busStopCode,
                        busServiceNo: item.busServiceNumber
                    )
                favourites.remove(at: index)
                items.removeAll {
                    $0.arrival.busStopCode == item.busStopCode
                        && $0.arrival.arrival.serviceNo == item.busServiceNumber
                }
            } catch {
                showError(
                    .init(
                        "shield.slash.fill",
                        title: "Delete failed",
                        description: error.localizedDescription
                    )
                )
            }
        }
    }

    func onMove(from source: IndexSet, to destination: Int) {
        Task { @MainActor in
            favourites.move(fromOffsets: source, toOffset: destination)
            let orderedIDs = favourites.map(\.id)
            do {
                try await SwiftDataStore.shared.store.reorderFavourites(ids: orderedIDs)
            } catch {
                showError(
                    .init(
                        "shield.slash.fill",
                        title: "Moving failed",
                        description: error.localizedDescription
                    )
                )
                await task()
            }
        }
    }
}
