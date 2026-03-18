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

@Observable
@MainActor
final class BusStopDetailsViewModel {
	
	let busStop: BusStop
	var arrivalItems = [ArrivalItemViewModel]()
	var errorMessage: String?

	@ObservationIgnored let busArrivalRepository = BusArrivalRepository(
		networkClient: NetworkClient(),
	)
	init(busStop: BusStop) {
		self.busStop = busStop
	}

	func fetchArrivalForBusStop() async {
		errorMessage = nil
		do {
			let arrival = try await busArrivalRepository.fetch(for: busStop.busStopCode)
			arrivalItems = arrival.services
				.map{ .init(item: .init(busStopCode: busStop.busStopCode, arrival: $0))}

		} catch {
			errorMessage = error.localizedDescription
		}
	}

	func startRefreshing() async {
		try? await Task.sleep(for: .seconds(1))
		await fetchArrivalForBusStop()
	}
}
