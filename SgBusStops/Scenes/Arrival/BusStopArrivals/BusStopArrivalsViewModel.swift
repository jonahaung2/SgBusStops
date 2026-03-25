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
	let busStop: BusStop
	var arrivalItems = [ArrivalRowViewModel]()
	var serviceRoutes = [BusServiceRoute]()

	@ObservationIgnored let busArrivalRepository = BusArrivalRepository(
		networkClient: NetworkClient(),
	)
	init(busStop: BusStop) {
		self.busStop = busStop
	}

	func fetchArrivalForBusStop() async {
		clearError()
		loading(true)
		do {
			let serviceNumbers = try await SwiftDataStore.shared.busRouteStore
				.serviceNumbers(busStopCode: busStop.busStopCode)

			let routes = try await AsyncOrderedStream
				.mapOrdered(inputs: serviceNumbers) { number in
				let routes = try await SwiftDataStore.shared.busRouteStore.routes(serviceNo: number)
				return await routes.buildServiceRoutes()
			}
			serviceRoutes = routes
				.flatMap{ $0 }
				.filter { $0.contains(stopCode: busStop.busStopCode )}
			
			let arrival = try await busArrivalRepository.fetch(for: busStop.busStopCode)
			let existing = Dictionary(
				uniqueKeysWithValues: arrivalItems.map { ($0.id, $0) },
			)
			arrivalItems = arrival.services.map { service in
				let item = ArrivalItem(busStop: busStop, arrival: service)
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
