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

@Observable
final class NearbyStopsViewModel: ViewModel {

	private(set) var nearbyStops = [BusStop]()

	func set(nearbyStops: [BusStop]) {
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
}

extension BusStop {
	var mapItem: MapItem {
		.init(desc, coordinate: coordinate)
	}
}
