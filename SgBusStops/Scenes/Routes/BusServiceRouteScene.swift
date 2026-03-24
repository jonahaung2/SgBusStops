//
//  BusServiceRouteScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/3/26.
//

import SwiftUI
import Services
import Models

struct BusServiceRouteScene: View {

	@State private var viewModel: BusServiceRouteViewModel
	@Environment(BusStore.self) private var busStore

	init(arrival: ArrivalItem) {
		_viewModel = .init(
			wrappedValue: .init(arrival: arrival)
		)
	}

    var body: some View {
		List {
			if let error = viewModel.error {
				ContentUnavailableView(
					error.title,
					systemImage: error.imageName,
					description: Text(error.description)
				)
			} else {
				if viewModel.routes.isEmpty == false {
					ForEach(viewModel.routes, id: \.id) { route in
						if let stop = busStore.busStop(for: route.busStopCode) {
							BusRouteCell(
								route: route,
								busStop: stop,
								rank:
										.rank(
											for: route,
											routes: viewModel.routes,
											item: viewModel.item
										)
							)
						}
					}
				} else {
					ZStack {
						ProgressView().controlSize(.mini)
					}.frame(maxWidth: .infinity)
						.frame(height: 400)

				}
			}
		}
		.navigationTitle(viewModel.item.arrival.serviceNo)
		.navigationSubtitle(viewModel.item.busStop.desc)
		.task {
			await viewModel.task()
		}
    }
}

public enum RouteRank: Hashable {
	case past, current, upcoming

	static func rank(for route: BusRoute, routes: [BusRoute], item: ArrivalItem) -> RouteRank {
		if route.busStopCode == item.busStop.busStopCode {
			return .current
		}
		let position = routes.first(
			where: { $0.busStopCode == item.busStop.busStopCode && $0.serviceNo
				== item.arrival.serviceNo })?.stopSequence ?? 0
		return route.stopSequence < position ? .past : .upcoming
	}
}
