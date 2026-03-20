//
//  BusStopCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import Services
import SwiftUI
import UI
internal import _LocationEssentials

struct BusStopCell: View {

	let busStop: BusStop
	@Environment(\.currentLocation) private var currentLocation
	@Environment(NavRouter.self) private var navRouter

	var body: some View {
		Button {
			navRouter.push(busStop)
		} label: {
			HStack {
				VStack(alignment: .leading, spacing: 0) {
					Text(busStop.desc)
						.font(.headline)
					Text(busStop.roadName)
						.font(.footnote)
						.foregroundStyle(.secondary)
				}

				.multilineTextAlignment(.leading)

				Spacer()
				VStack(alignment: .leading, spacing: 0) {
					Text(busStop.busStopCode)
						.monospacedDigit()
						.fontWidth(.compressed)

					Text("\(currentLocation.distance(to: busStop.location)) km")
						.font(.caption2)
						.foregroundStyle(.secondary)
				}
			}
			.lineHeight(.multiple(factor: 1.3))
		}
		.buttonStyle(.borderless)
		.transition(.identity)
		.id(busStop.id)
	}
}
