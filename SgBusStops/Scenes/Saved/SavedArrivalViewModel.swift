//
//  SavedArrivalViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Models
import Services
import SwiftUI

@Observable
final class SavedArrivalViewModel: ViewModel {

	var items = [ArrivalRowViewModel]()
	private let fetcher = BusStopFetcher()
}

extension SavedArrivalViewModel {

	@concurrent
	func task() async {
		let favourites = await FavouriteArrivalModel.fetchAll()
		if favourites.isEmpty {
			await showError(
				.init(
					"star.slash",
					title: "No Saved Arrivals",
					description: "You haven’t saved any favorite arrivals. Add one by tapping the star icon at your preferred bus stop."
				)
			)
			return
		}
		await clearError()
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

			Task { @MainActor in
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

			}
		} catch {
			await showError(
				.init(
					"star.slash",
					title: "No Saved Arrivals",
					description: error.localizedDescription
				)
			)
		}
	}

	func onDelete(_ index: Int) {
		Task {
			let item = items[index]
			do {
				try await FavouriteArrivalModel
					.remove(
						busStopCode: item.item.busStop.busStopCode,
						busServiceNo: item.item.arrival.serviceNo,
					)
				items.remove(at: index)
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
		items.move(fromOffsets: source, toOffset: destination)

		let orderedIDs = items.map {
			FavouriteArrivalModel.makeID(
				busStopCode: $0.item.busStop.busStopCode,
				busServiceNumber: $0.item.arrival.serviceNo,
			)
		}

		Task { @MainActor in
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
