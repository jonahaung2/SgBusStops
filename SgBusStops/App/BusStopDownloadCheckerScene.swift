//
//  BusStopDownloadCheckerScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Services
import SwiftUI
import UI

struct BusStopDownloadCheckerScene: View {
    @State private var store = BusStopStore()

	@State private var hasLoaded = false
    var body: some View {
		if hasLoaded, !store.busStops.isEmpty {
	            MainTabView()
	                .environment(store)
	        } else {
			AnimatedText(text: "SG Bus Stops", preset: .spring)
				.task {
					await store.fetch()
					try? await Task.sleep(for: .seconds(1))
					hasLoaded = true
				}
        }
    }
}
