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

	let busStop: Stop
	let onSelect: (Stop) -> Void

	@Environment(\.currentLocation) private var currentLocation

	var body: some View {
		Button {
			onSelect(busStop)
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
						.foregroundStyle(.secondary)
						.italic()

					Text("\(currentLocation.distance(to: busStop.location)) km")
						.font(.caption2.width(.condensed))
				}
			}
		}
		.lineHeight(.multiple(factor: 1.3))
		.id(busStop.id)
	}
}
