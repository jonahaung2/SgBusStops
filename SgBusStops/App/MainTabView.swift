//
//  MainTabView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Services
import SwiftUI
import Models

struct MainTabView: View {

	@State private var router = Router()
	private let locationService = LocationService()
	@Environment(\.scenePhase) private var scenePhase

	var body: some View {
		TabView(selection: $router.currentTab) {
			ForEach(router.navRouters) { navRouter in
				Tab(value: navRouter.id, role: navRouter.id.canSearch ? .search : nil) {
					NavigationStack(path: .init(get: { navRouter.path }, set: { navRouter.path = $0 })) {
						view(for: navRouter.id)
							.navigationTitle(navRouter.id.description)
							.navigationDestination(for: BusStop.self) { busStop in
								BusStopDetailsScene(busStop)
							}
					}
					.environment(navRouter)
				} label: {
					Label(navRouter.id.description, systemImage: navRouter.id.systemName)
						.labelStyle(.iconOnly)
				}
			}
		}
		.tabBarMinimizeBehavior(.onScrollDown)
		.environment(locationService)
		.listSectionSpacing(8)
		.listSectionMargins(.horizontal, 4)
		.listSectionSeparator(.hidden)
		.task(id: scenePhase) {
			if scenePhase == .active {
				await locationService.startLocation()
			}
		}
	}

	@ViewBuilder
	private func view(for tab: TabPath) -> some View {
		switch tab {
		case .nearBy:
			NearByScene()
		case .busStops:
			BusStopsScene()
		case .settings:
			SettingsScene()
		case .saved:
			SavedArrivalsScene()
		}
	}
}
