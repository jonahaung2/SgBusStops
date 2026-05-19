//
//  NearByViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Foundation
import Models
import Services
import SgMaps
import CoreLocation

@Observable
final class NearbyStopsViewModel: ViewModel {

	private(set) var nearbyStops = [Stop]()

	func set(nearbyStops: [Stop]) {
		clearError()
		self.nearbyStops = nearbyStops
		if self.nearbyStops.isEmpty {
			let distance: Double = {
				let distance = UserDefaults.standard.double(forKey: "nearbyDistance")
				if distance.isZero {
					return 1000
				}
				return distance
			}()
			showError(
				.init(
					"signpost.right.and.left.fill",
					title: "No bus stops found",
					description:
						"We couldn’t find any bus stops within \(Int(distance)) m nearby. You can expand the search radius in Settings to discover more stops"
				)
			)
		}
	}

	@concurrent
	func fetchNearby(location: LocationResult, distance: Double) async {
		do {
			guard distance.isFinite, distance >= 0 else {
				return
			}
			let stops = try await SwiftDataStore.shared.store.busStopAll()
			let origin = CLLocation(latitude: location.latitude, longitude: location.longitude)
			let matched = stops.compactMap { busStop -> (Stop, CLLocationDistance)? in
				let stopLocation = CLLocation(latitude: busStop.latitude, longitude: busStop.longitude)
				let stopDistance = origin.distance(from: stopLocation)
				guard stopDistance <= distance else {
					return nil
				}
				return (busStop, stopDistance)
			}

			let results = matched.sorted { $0.1 < $1.1 }.map(\.0)
			await set(nearbyStops: results)
		} catch {
			await showError(error)
		}
	}
}

extension Stop {
	var mapItem: MapItem {
		.init(desc, coordinate: coordinate)
	}
}
