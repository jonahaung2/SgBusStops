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

	let item: ArrivalItem
	var routes = [BusRoute]()

	init(arrival: ArrivalItem) {
		self.item = arrival
	}

	func task() async {
		do {
			let routes = try await SwiftDataStore.shared.busRouteStore
				.routes(serviceNo: item.arrival.serviceNo)
			let serviceRoutes = routes.buildServiceRoutes()
				.filter { $0.contains(stopCode: item.busStop.busStopCode)}
			let stops = serviceRoutes.first?.stops ?? []
			var result = [BusRoute]()

			stops.forEach { route in

				result.append(route)
			}
			self.routes = result
		} catch {
			showError(error)
		}
	}

	public func route(for serviceNo: String, direction: Int) async throws
	-> BusServiceRoute? {
	let allRoutes = try await SwiftDataStore.shared.busRouteStore.fetchAll()
		let build = allRoutes.buildServiceRoutes()

		return build.route(serviceNo: serviceNo, direction: direction)
	}

	public func remaining(serviceNo: String, direction: Int, after busStopCode: String)
	async throws -> [BusRoute] {
		try await route(for: serviceNo, direction: direction)?.remainingStops(after: busStopCode)
		?? []
	}
	public func remaining(serviceNo: String, direction: Int, including busStopCode: String)
	async throws -> [BusRoute] {
		try await route(for: serviceNo, direction: direction)?.remainingStops(including: busStopCode) ?? []
	}
}
extension Array where Element == BusRoute {

	/// Group by serviceNo → direction → sorted stops
	public func groupedByService() -> [String: [Int: [BusRoute]]] {
		Dictionary(grouping: self) { $0.serviceNo }
			.mapValues { routes in
				Dictionary(grouping: routes) { $0.direction }
					.mapValues { $0.sorted { $0.stopSequence < $1.stopSequence } }
			}
	}
	/// Group by serviceNo → direction → sorted stops
	public func groupedByDirection() -> [BusDirection: [Int: [BusRoute]]] {
		Dictionary(grouping: self) { $0.busDirectioon }
			.mapValues { routes in
				Dictionary(grouping: routes) { $0.direction }
					.mapValues { $0.sorted { $0.stopSequence < $1.stopSequence } }
			}
	}

	/// Flatten into structured route objects
	public func buildServiceRoutes() -> [BusServiceRoute] {
		groupedByService()
			.flatMap { serviceNo, directions in
				directions.map { direction, stops in
					BusServiceRoute(
						serviceNo: serviceNo,
						direction: direction,
						stops: stops
					)
				}
			}
	}
}

extension Array where Element == BusServiceRoute {

	/// StopCode → [Routes]
	public func indexByStop() -> [String: [BusServiceRoute]] {
		var result: [String: [BusServiceRoute]] = [:]

		for route in self {
			for stop in route.stops {
				result[stop.busStopCode, default: []].append(route)
			}
		}

		return result
	}

	/// Get route by service + direction
	public func route(serviceNo: String, direction: Int) -> BusServiceRoute? {
		first {
			$0.serviceNo == serviceNo && $0.direction == direction
		}
	}

	/// Find all routes that pass BOTH stops (basic trip planner)
	public func routes(from start: String, to end: String) -> [BusServiceRoute] {
		filter {
			$0.contains(stopCode: start) && $0.contains(stopCode: end)
		}
	}
}

extension BusServiceRoute {

	/// Remaining stops AFTER a given stop (excluding current)
	func remainingStops(after stopCode: String) -> [BusRoute] {
		guard let index = stops.firstIndex(where: { $0.busStopCode == stopCode }),
			  index + 1 < stops.count
		else { return [] }

		return Array(stops[(index + 1)...])
	}

	/// Remaining stops INCLUDING current stop
	func remainingStops(including stopCode: String) -> [BusRoute] {
		guard let index = stops.firstIndex(where: { $0.busStopCode == stopCode })
		else { return [] }

		return Array(stops[index...])
	}
}
