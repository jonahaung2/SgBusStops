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
		errorMessage = nil
		do {
			let items = try await AsyncOrderedStream.mapOrdered(inputs: favourites) { favourite in
				let arrival = try await self.fetcher
					.fetchArrivalForBusService(
						busServiceNumber: favourite.busServiceNumber,
						busStopCode: favourite.busStopCode
					)
				let items: [ArrivalItem] = await MainActor.run {
					arrival.map { ArrivalItem(busStopCode: favourite.busStopCode, arrival: $0) }
				}
				return items
				
			}
			self.items = items.flatMap(\.self).map{ .init(item: $0)}
		} catch {
			errorMessage = error.localizedDescription
			items = []
		}
	}
}
