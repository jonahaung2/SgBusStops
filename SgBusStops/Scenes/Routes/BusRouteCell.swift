//
//  BusRouteCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/3/26.
//

import SwiftUI
import Services
import Models

struct BusRouteCell: View {
	let route: BusRoute
	let busStop: BusStop
	let rank: RouteRank
	@Environment(NavRouter.self) private var navRouter

    var body: some View {
		LabeledContent {
			Text(route.stopSequence.formatted())
				.font(.caption2)
				.fontWeight(.black)
				.italic()
				.foregroundStyle(.secondary)
		} label: {
			Text("\(busStop.desc)")
				.font(.headline)
			Text(busStop.roadName)
				.foregroundStyle(.secondary)

		}
		.multilineTextAlignment(.leading)
		.lineHeight(.multiple(factor: 1.3))
		.badge(route.busStopCode)
		.badgeProminence(rank == .past ? .decreased : .standard)
		.foregroundStyle(rank == .past ? .tertiary : .primary)
		._onButtonGesture { _ in

		} perform: {
			navRouter.push(busStop)
		}

    }
}
