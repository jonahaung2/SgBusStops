//
//  BusStopDetailsViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Foundation
import Models
import Services

final class BusStopArrivalsViewModel: ViewModel {
	let busStopCode: String
	var arrivalItems = [ArrivalRowViewModel]()
	var serviceRoutes = [BusRoutes]()

	@ObservationIgnored let busArrivalRepository = BusArrivalRepository(
		networkClient: NetworkClient(),
	)
	init(busStopCode: String) {
		self.busStopCode = busStopCode
	}

	func fetchArrivalForBusStop() async {
		clearError()
		loading(true)
		do {
			serviceRoutes = try await SwiftDataStore.shared.store
				.busServiceStops(busStopCode: busStopCode)

			let arrival = try await busArrivalRepository.fetch(for: busStopCode)
			let existing = Dictionary(
				uniqueKeysWithValues: arrivalItems.map { ($0.id, $0) },
			)
			arrivalItems = arrival.services.map { service in
				let item = BusStopArrival(busStopCode: busStopCode, arrival: service)
				if let model = existing[item.id] {
					model.update(item: item)
					return model
				}
				return .init(item: item)
			}
			loading(false)
		} catch {
			showError(
				error,
				offlineTitle: "Live Arrivals Unavailable",
				offlineDescription: "You're offline. Connect to the internet to load real-time bus arrival timings for this stop.",
				fallbackTitle: "Unable to Load Arrivals"
			)
		}
	}

	func startRefreshing() async {
		try? await Task.sleep(for: .seconds(1))
		await fetchArrivalForBusStop()
	}
}
