//
//  BusServiceRouteViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/3/26.
//

import Models
import Client
import Services
import Observation

@Observable
final class BusServiceRouteViewModel: ViewModel {

	let item: BusRoutes
	let busStop: Stop?
	var routes = [BusRoutingInfo]()

	init(busRoute: StopBusRoutes) {
		self.item = busRoute.route
		self.busStop = busRoute.stop
		self.routes = busRoute.route.routes
	}

	func task() async {
		do {
			let serviceRoutes = try await SwiftDataStore.shared.store
				.busServiceStops(serviceNo: item.busNumber)
				.filter { $0.contains(stopCode: busStop?.busStopCode ?? "")}
			let stops = serviceRoutes.first?.routes ?? []
			var result = [BusRoutingInfo]()

			stops.forEach { route in

				result.append(route)
			}
			self.routes = result
		} catch {
			showError(error)
		}
	}

	public func route(for serviceNo: String, direction: Int) async throws
	-> BusRoutes? {
		let allRoutes = try await SwiftDataStore.shared.store.routeAll()
		let build = allRoutes.buildServiceRoutes()

		return build.route(busService: serviceNo, direction: direction)
	}

	public func remaining(serviceNo: String, direction: Int, after busStopCode: String)
	async throws -> [BusRoutingInfo] {
		try await route(for: serviceNo, direction: direction)?.remainingStops(after: busStopCode)
		?? []
	}
	public func remaining(serviceNo: String, direction: Int, including busStopCode: String)
	async throws -> [BusRoutingInfo] {
		try await route(for: serviceNo, direction: direction)?.remainingStops(including: busStopCode) ?? []
	}
}
extension Array where Element == BusRoutingInfo {

	/// Group by serviceNo → direction → sorted stops
	public func groupedByService() -> [String: [BusDirection: [BusRoutingInfo]]] {
		Dictionary(grouping: self) { $0.serviceNo }
			.mapValues { routes in
				Dictionary(grouping: routes) { $0.direction }
					.mapValues { $0.sorted { $0.stopSequence < $1.stopSequence } }
			}
	}
	/// Group by serviceNo → direction → sorted stops
	public func groupedByDirection() -> [BusDirection: [BusDirection: [BusRoutingInfo]]] {
		Dictionary(grouping: self) { $0.direction }
			.mapValues { routes in
				Dictionary(grouping: routes) { $0.direction }
					.mapValues { $0.sorted { $0.stopSequence < $1.stopSequence } }
			}
	}

	/// Flatten into structured route objects
	public func buildServiceRoutes() -> [BusRoutes] {
		groupedByService()
			.flatMap { serviceNo, directions in
				directions.map { direction, stops in
					BusRoutes(
						busNumber: serviceNo,
						direction: direction,
						stops: stops
					)
				}
			}
	}
}

extension Array where Element == BusRoutes {

	/// StopCode → [Routes]
	public func indexByStop() -> [String: [BusRoutes]] {
		var result: [String: [BusRoutes]] = [:]

		for route in self {
			for stop in route.routes {
				result[stop.busStopCode, default: []].append(route)
			}
		}

		return result
	}

	/// Get route by service + direction
	public func route(busService: String, direction: BusDirection) -> BusRoutes? {
		first {
			$0.busNumber == busService && $0.direction == direction
		}
	}

	/// Find all routes that pass BOTH stops (basic trip planner)
	public func routes(from start: String, to end: String) -> [BusRoutes] {
		filter {
			$0.contains(stopCode: start) && $0.contains(stopCode: end)
		}
	}
}

extension BusRoutes {

	/// Remaining stops AFTER a given stop (excluding current)
	func remainingStops(after stopCode: String) -> [BusRoutingInfo] {
		guard let index = routes.firstIndex(where: { $0.busStopCode == stopCode }),
			  index + 1 < routes.count
		else { return [] }

		return Array(routes[(index + 1)...])
	}

	/// Remaining stops INCLUDING current stop
	func remainingStops(including stopCode: String) -> [BusRoutingInfo] {
		guard let index = routes.firstIndex(where: { $0.busStopCode == stopCode })
		else { return [] }

		return Array(routes[index...])
	}
}
