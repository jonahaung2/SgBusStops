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

final class StopBussesSceneViewModel: ViewModel {
	let busses: [Bus]
	init(_ busses: [Bus]) {
		self.busses = busses
	}
}
