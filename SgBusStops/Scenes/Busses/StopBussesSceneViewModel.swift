//
//  BussesViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 25/3/26.
//

import Client
import Foundation
import Models
import Services

@Observable
final class StopBussesSceneViewModel: ViewModel {
	
	let stop: Stop
	var busRoutes = [StopBusRoutes]()

	init(_ stop: Stop) {
		self.stop = stop
	}

	func task() async {
		do {
			let busses = try await stop.busses()
			let stop = self.stop
			busRoutes = try await AsyncOrderedStream.mapOrdered(inputs: busses) { bus in
				if let route = try await bus.routes().buildServiceRoutes().first {
					return StopBusRoutes(route: route, stop: stop)
				}
				return nil
			}.compactMap{ $0 }
		} catch {
			showError(error)
		}
	}
}
