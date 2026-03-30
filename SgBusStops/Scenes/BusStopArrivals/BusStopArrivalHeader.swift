//
//  BusStopArrivalHeader.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Models
import Pow
import Services
import SwiftUI
import UI

struct BusStopArrivalHeader: View {

	private let model: ArrivalRowViewModel
	@Environment(BusStore.self) private var store

	init(_ model: ArrivalRowViewModel) {
		self.model = model
	}

	var body: some View {
		HStack(alignment: .lastTextBaseline, spacing: 16) {

			if let stop = store.busStop(for: model.arrival.busStopCode),
				let distance = model.arrival.arrival.nextBus?.coordinate?.distance(
					to: stop.coordinate
				)
			{
				Text(
					"\(Image(systemName: "signpost.right.and.left.fill")) ⎯ \(distance.formatted()) km ⎯ \(Image(systemName: "bus"))"
				)
				.font(.caption2.width(.condensed))

			}
			Spacer()
			if let stop = store.busStop(for: model.arrival.busStopCode),
				let date = model.arrival.arrival.nextBus?.estimatedArrival {
				let activity = LiveActivityModel(
					busNumber: model.arrival.bus.busNumber,
					stopCode: model.arrival.busStopCode,
					stopName: stop.desc,
					date: date
				)
				LiveActivityBadge(model: activity)
			}

			Button {
				model.toggleFavourite()
			} label: {
				Image(systemName: "star")
					.foregroundStyle(
						model.isFavourite ? Color.yellow.gradient : Color.gray.gradient
					)
					.symbolVariant(model.isFavourite ? .fill : .none)
					.imageScale(model.isFavourite ? .medium : .small)
					.changeEffect(
						model.isFavourite
							? .spray {
								Group {
									Image(systemName: "star.fill").foregroundStyle(Color.red)
									Image(systemName: "star.fill").foregroundStyle(Color.blue)
									Image(systemName: "star.fill").foregroundStyle(Color.pink)
									Image(systemName: "star.fill").foregroundStyle(Color.orange)
								}
								.shadow(radius: 1)
							} : .spin,
						value: model.isFavourite,
						isEnabled: !model.isUpdatingFavourite,
					)
			}
			BusNumberText(model.arrival.arrival.serviceNo, .title1)
		}
	}
}
