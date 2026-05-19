//
//  NearbySheetViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 24/3/26.
//

import SwiftUI
import Services
import UI
import Models
internal import _LocationEssentials

final class NearbySheetViewModel: ViewModel {
	
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
			self.nearbyStops = results
		} catch {
			showError(error)
		}
	}
}
