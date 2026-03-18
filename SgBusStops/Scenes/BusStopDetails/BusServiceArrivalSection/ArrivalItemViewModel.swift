//
//  BusServiceArrivalSectionViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Models
import Services
import SwiftUI

@Observable
@MainActor
final class ArrivalItemViewModel: Identifiable {
	
	var id: String { busStopCode + busServiceArrival.serviceNo }
	var busServiceArrival: BusServicArrival
	let busStopCode: String
	var isFavourite: Bool = false
	var isUpdatingFavourite = false
	var favouriteErrorMessage: String?

	init(item: ArrivalItem) {
		self.busServiceArrival = item.arrival
		self.busStopCode = item.busStopCode
		fetchFavourite()
	}

	func toggleFavourite() {
		guard !isUpdatingFavourite else {
			return
		}

		let serviceNo = busServiceArrival.serviceNo
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
								busStopCode: busStopCode,
								busServiceNumber: serviceNo
							)
						)
				} else {
					try await FavouriteArrivalModel
						.remove(busStopCode: busStopCode, busServiceNo: serviceNo)
				}
				fetchFavourite()
			} catch {
				favouriteErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
			}
		}
	}
}

extension ArrivalItemViewModel {
	private func fetchFavourite() {
		let savedFavourite = FavouriteArrivalModel.fetch(
			busStopCode: busStopCode,
			busServiceNo: busServiceArrival
				.serviceNo
		)
		isFavourite = savedFavourite != nil
	}
}
