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
    @Environment(LocationService.self) private var locationService
	@Environment(NavRouter.self) private var navRouter

    var body: some View {
		Button {
			navRouter.path.append(busStop)
		} label: {
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					let desc = Text(busStop.desc)
						.font(.title3.weight(.semibold))

					let road = Text(busStop.roadName)
						.font(.footnote.weight(.medium))
						.foregroundStyle(.secondary)

					Text("\(desc)\n\(road)")
						.multilineTextAlignment(.leading)

					Spacer()
					VStack(alignment: .leading, spacing: 0) {
						Text(busStop.busStopCode)
							.font(.headline.width(.compressed))
						if let currentLocation = locationService.location {
							let distance = busStop.distance(from: currentLocation.clLocation.coordinate)
							Text("\(distance.formatted(.number.precision(.fractionLength(2)))) km")
								.font(.caption2)
								.foregroundStyle(.secondary)
						}
					}
				}

			}
		}
		.tint(Color.primary)
		.buttonStyle(.borderless)
		.transition(.identity)
    }
}
