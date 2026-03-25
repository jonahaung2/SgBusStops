//
//  BusStopServicesViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 25/3/26.
//

import Client
import Foundation
import Models
import Services

final class BusStopServicesViewModel: ViewModel {
	let busStop: BusStop
	var serviceRoutes = [BusServiceRoute]()


	init(busStop: BusStop) {
		self.busStop = busStop
	}

	func task() async {
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
}
