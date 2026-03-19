//
//  BusServiceArrivalSection.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct BusServiceArrivalSection: View {

	private let model: ArrivalItemViewModel
	@Environment(BusStopStore.self) private var store

	init(_ model: ArrivalItemViewModel) {
		self.model = model
	}

	var body: some View {
		Section {
			BusServiceArrivalCell(model)
		} header: {
			ArrivalItemDefaultHeaderView(model)
		} footer: {
			HStack {
				if let codeA = model.item.arrival.nextBus?.originCode,
					let original = store.busStop(
						for: codeA
					)
				{
					if let code = model.item.arrival.nextBus?.destinationCode,
						let destination = store.busStop(
							for: code
						)
					{
						Text(
							"\(Image(systemName: "point.topright.arrow.triangle.backward.to.point.bottomleft.filled.scurvepath"))  \(original.desc) \(Image(systemName: "arrow.right")) \(destination.desc)"
						)
					} else {
						Text(original.desc)
					}
				}
				Spacer()
				model.item.arrival.operatorCode.logo.frame(height: 10)
			}.font(.footnote)
		}
	}
}
