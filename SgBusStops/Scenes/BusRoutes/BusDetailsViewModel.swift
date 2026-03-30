//
//  BusDetailsViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 27/3/26.
//

import Foundation
import Models
import Services

@Observable
final class BusRoutesViewModel: ViewModel {

	let busRoutes: BusRoutes
	init(_ busRoutes: BusRoutes) {
		self.busRoutes = busRoutes
	}

	func task() async {
//		do {
//
//		} catch {
//			showError(error)
//		}
	}
}
