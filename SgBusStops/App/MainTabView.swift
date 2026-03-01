//
//  MainTabView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import MRTMap
import SwiftUI

struct MainTabView: View {
    @State private var router = Router()
    @State private var selectedMRTName: String?

    var body: some View {
        TabView(selection: $router.currentTab) {
            ForEach(TabPath.allCases, id: \.self) { tab in
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
        .listSectionSpacing(4)
        .listSectionMargins(.horizontal, 4)
        .listSectionSeparator(.hidden)
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
        }
    }
}
