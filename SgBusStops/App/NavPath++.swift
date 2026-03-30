//
//  NavPath++.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 27/3/26.
//

import Models
import Services
import SwiftUI

extension NavPath {
	@ViewBuilder
	public func destiNation() -> some View {
		switch self {
		case .busRoutes(let item):
			BusRoutesScene(item)
		case .stopDetail(let stop):
			StopBussesScene(stop)
		case .stopArrivals(let stop):
			BusStopArrivalsScene(stop)
		case .routesOfStop(let item):
			BusServiceRouteScene(busRoute: item)
		}
	}
}
