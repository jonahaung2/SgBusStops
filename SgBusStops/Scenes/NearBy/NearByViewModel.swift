//
//  NearByViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//
import Client
import Foundation
import Models
import Services
import SgMaps

@Observable
@MainActor
final class NearbyStopsViewModel {
	var nearbyStops = [BusStop]()
}

extension BusStop {
	var mapItem: MapItem {
		.init(desc, coordinate: coordinate)
	}
}
