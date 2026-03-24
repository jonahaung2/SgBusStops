//
//  FavouriteArrivalViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Models
import Services
import SwiftUI

@Observable
final class FavouriteArrivalViewModel: ViewModel {

	var items = [ArrivalRowViewModel]()
	var favourites = [FavouriteArrival]()
	private let fetcher = BusStopFetcher()
}

extension FavouriteArrivalViewModel {

	func task() async {
		loading(true)
		let favourites = FavouriteArrivalModel.fetchAll()
		self.favourites = favourites
		if favourites.isEmpty {
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
		clearError()
		do {
			let items = try await AsyncOrderedStream.mapOrdered(inputs: favourites) { favourite in
				let arrival = try await self.fetcher
					.fetchArrivalForBusService(
						busServiceNumber: favourite.busServiceNumber,
						busStopCode: favourite.busStopCode,
					)
				if let busStop = await favourite.busStop() {
					return await MainActor.run {
						arrival.map { ArrivalItem(busStop: busStop, arrival: $0) }
					}
				}
				return []
			}
			let flattened = items.flatMap(\.self)
			loading(false)
			let existing = Dictionary(
				uniqueKeysWithValues: self.items.map { ($0.id, $0) },
			)
			self.items = flattened.map { item in
				if let model = existing[item.id] {
					model.update(item: item)
					return model
				}
				return .init(item: item)
			}
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
				try await FavouriteArrivalModel
					.remove(
						.init(
							busStopCode: item.busStopCode,
							busServiceNumber: item.busServiceNumber
						)
					)
				favourites.remove(at: index)
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
			items.move(fromOffsets: source, toOffset: destination)
			let orderedIDs = favourites.map { $0.id }
			do {
				try await FavouriteArrivalModel.reorder(ids: orderedIDs)
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
