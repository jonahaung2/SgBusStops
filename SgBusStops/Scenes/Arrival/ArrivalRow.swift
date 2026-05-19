//
//  ArrivalRow.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 20/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct ArrivalRow: View {
	private let model: ArrivalRowViewModel

	@Environment(NavRouter.self) private var navRouter
	@Environment(BusStore.self) private var store
	init(_ model: ArrivalRowViewModel) {
		self.model = model
	}

	private var serviceArrival: BusArrival {
		model.arrival.arrival
	}

	var body: some View {
		Grid(alignment: .centerLastTextBaseline, horizontalSpacing: 0) {
			GridRow(alignment: .lastTextBaseline) {
				ForEach(
					Array(model.arrival.arrival.arrivals().enumerated()),
					id: \.offset,
				) { index, arrival in
					ArrivalColumn(
						arrival: arrival,
						rank: index + 1,
					)
					.frame(maxWidth: .infinity)
				}
			}
		}
		._onButtonGesture(
			pressing: { _ in

			},
			perform: {

				if let stop = store.busStop(for: model.arrival.busStopCode) {
					navRouter
						.push(
							.routesOfStop(
								.init(route: .init(bus: model.arrival.bus, stops: []), stop: stop)
							)
						)
				}

			}
		)
		.transition(.identity)
	}
}
extension BusArrival {
	func arrivals() -> [Arrival] {
		var arrivals: [Arrival] = []
		if let nextBus { arrivals.append(nextBus) }
		if let nextBus2 { arrivals.append(nextBus2) }
		if let nextBus3 { arrivals.append(nextBus3) }
		return arrivals
	}
}
