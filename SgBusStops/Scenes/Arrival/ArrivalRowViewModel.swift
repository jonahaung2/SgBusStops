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
final class ArrivalRowViewModel: ViewModel, Identifiable {

	var id: String { arrival.id }
	var arrival: BusStopArrival

	var isFavourite = false
	var isUpdatingFavourite = false

	init(item: BusStopArrival) {
		self.arrival = item
		super.init()
		fetchFavourite()

	}

	func update(item: BusStopArrival) {
		self.arrival = item
		fetchFavourite()
	}

	func toggleFavourite() {
		guard !isUpdatingFavourite else {
			return
		}

		let serviceNo = arrival.arrival.serviceNo
		let shouldSave = !isFavourite
		isUpdatingFavourite = true

		Task { @MainActor in
			defer {
				isUpdatingFavourite = false
			}

			do {
				if shouldSave {
					try await SwiftDataStore.shared.store
						.save(
							FavouriteArrivalModel(
								busStopCode: arrival.busStopCode,
								busServiceNumber: serviceNo
							)
						)
				} else {
					try await SwiftDataStore.shared.store
						.removeFavourite(
							busStopCode: arrival.busStopCode,
							busServiceNo: serviceNo
						)
				}
				fetchFavourite()
			} catch {
				showError(error)
			}
		}
	}
}

extension ArrivalRowViewModel {
	func fetchFavourite() {
		let savedFavourite = FavouriteArrivalModel.fetch(
			busStopCode: arrival.busStopCode,
			busServiceNo: arrival.arrival
				.serviceNo,
		)
		isFavourite = savedFavourite != nil
	}
}
