//
//  LiveActivityModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 29/3/26.
//

import Foundation

struct LiveActivityModel: Sendable, Hashable, Identifiable {
	var id: String { busNumber + stopCode }
	let busNumber: String
	let stopCode: String
	let stopName: String
	var date: Date

	init(busNumber: String, stopCode: String, stopName: String, date: Date) {
		self.busNumber = busNumber
		self.stopCode = stopCode
		self.stopName = stopName
		self.date = date
	}
}
