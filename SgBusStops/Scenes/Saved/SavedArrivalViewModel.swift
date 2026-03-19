//
//  SavedArrivalViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import SwiftUI
import Models
import Services

@Observable
@MainActor
final class SavedArrivalViewModel {
	var items = [ArrivalItemViewModel]()
	var errorMessage: String?
	private let fetcher = BusStopFetcher()
}
extension SavedArrivalViewModel {
	func task() async {
		let favourites = FavouriteArrivalModel.fetchAll()
		if favourites.isEmpty {
			errorMessage = "You haven't saved any arrivals."
			return
		}
		errorMessage = nil
		do {
			let items = try await AsyncOrderedStream.mapOrdered(inputs: favourites) { favourite in
				let arrival = try await self.fetcher
					.fetchArrivalForBusService(
						busServiceNumber: favourite.busServiceNumber,
						busStopCode: favourite.busStopCode
					)
				if let busStop = await favourite.busStop() {
					let items: [ArrivalItem] = await MainActor.run {
						arrival.map { ArrivalItem(busStop: busStop, arrival: $0) }
					}
					return items
				}
				return []
			}
			let flattened = items.flatMap(\.self)
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
		} catch {
			errorMessage = error.localizedDescription
			items = []
		}
	}

	func onDelete(_ index: Int) {
		Task {
			let item = items[index]
			do {
				try await FavouriteArrivalModel
					.remove(
						busStopCode: item.item.busStop.busStopCode,
						busServiceNo: item.item.arrival.serviceNo
					)
				items.remove(at: index)
			} catch {
				errorMessage = error.localizedDescription
			}
		}
	}

	func onMove(from source: IndexSet, to destination: Int) {
		items.move(fromOffsets: source, toOffset: destination)

		let orderedIDs = items.map {
			FavouriteArrivalModel.makeID(
				busStopCode: $0.item.busStop.busStopCode,
				busServiceNumber: $0.item.arrival.serviceNo
			)
		}

		Task { @MainActor in
			do {
				try await FavouriteArrivalModel.reorder(ids: orderedIDs)
			} catch {
				errorMessage = error.localizedDescription
				await task()
			}
		}
	}
}
