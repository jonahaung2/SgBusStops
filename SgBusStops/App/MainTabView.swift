//
//  MainTabView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Services
import SwiftUI

struct MainTabView: View {
	
    @State private var router = Router()
	private let locationService = LocationService()
	@Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $router.currentTab) {
            ForEach(TabPath.allCases) { tab in
                Tab(value: tab, role: tab.canSearch ? .search : nil) {
                    NavigationStack {
                        view(for: tab)
                            .navigationTitle(tab.description)
                    }
                } label: {
                    Label(tab.description, systemImage: tab.systemName)
                        .labelStyle(.iconOnly)
                }
            }
        }
		.redacted(reason: locationService.isRequestingLocation ? .placeholder : .init())
		.environment(locationService)
        .listSectionSpacing(4)
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
