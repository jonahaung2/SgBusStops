//
//  MainTabView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import Services
import SwiftUI
import UI

struct MainTabView: View {

	@State private var router = Router()
	@State private var liveActivity = LiveActivityViewModel()
	private let locationService = LocationService()
	@Environment(\.scenePhase) private var scenePhase
	let store: BusStore

	var body: some View {
		TabView(selection: $router.currentTab) {
			ForEach(router.navRouters) { navRouter in
				let tab: TabPath = navRouter.id
				Tab(value: tab, role: tab.canSearch ? .search : nil) {
					NavigationStack(path: navRouter.pathBinding) {
						view(for: tab)
							.navigationTitle(tab.description)
							.navigationDestination(for: NavPath.self) { path in
								path.destiNation()
							}
					}
					.environment(navRouter)
				} label: {
					Label(tab.description, systemImage: tab.systemName)
						.labelStyle(.iconOnly)
				}
			}
		}
		.tabBarMinimizeBehavior(.onScrollDown)
		.environment(store)
		.environment(locationService)
		.environment(liveActivity)
		.environment(\.currentLocation, locationService.location ?? .default)
		.listSectionSpacing(8)
		.listSectionMargins(.horizontal, 0)
		.listRowSpacing(0)
		.listSectionSeparator(.hidden)
		.buttonStyle(.borderless)
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
			FavouriteArrivalsScene()
		}
	}
}
