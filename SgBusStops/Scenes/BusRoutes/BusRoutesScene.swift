//
//  BusDetailsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 27/3/26.
//

import SwiftUI
import Services
import Models

struct BusRoutesScene: View {

	@State private var viewModel: BusRoutesViewModel
	@Environment(BusStore.self) private var busStopStore
	@Environment(NavRouter.self) private var navRouter

	init(_ busRoutes: BusRoutes) {
		_viewModel = .init(wrappedValue: .init(busRoutes))
	}

    var body: some View {
		List {
			ForEach(viewModel.busRoutes.routes) { route in
				BusRoutesCell(route: route)
			}
		}
		.navigationTitle(viewModel.busRoutes.busNumber)
		.navigationSubtitle("Direction \(viewModel.busRoutes.direction.rawValue.formatted())")
		.task {
			await viewModel.task()
		}
    }
}
