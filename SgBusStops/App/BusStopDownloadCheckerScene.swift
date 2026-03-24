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

    @State private var store = BusStore()
    @State private var hasLoaded = false
    @State private var loadTrigger = UUID()
	@AppStorage("has_set_up_data") private var hasSetUpData: Bool = false

    var body: some View {
		if hasLoaded, store.isReady {
            MainTabView()
                .environment(store)
        } else {
			VStack(spacing: 20) {
				AnimatedText(text: "SG Bus Arrival", preset: .bounce)
				if let error = store.error {
					ContentUnavailableView {
						Label(error.title, systemImage: error.imageName)
					} description: {
						Text(error.description)
					} actions: {
						Button("Retry") {
							hasLoaded = false
							loadTrigger = UUID()
						}
					}
				} else if store.isLoading && !hasSetUpData {
					ProgressView().controlSize(.mini)
					Text("Please wait while we set up the app for the first time...")
						.font(.caption)
						.foregroundStyle(.secondary)
						.padding(.horizontal)
				}
			}
                .task(id: loadTrigger) {
					try? await Task.sleep(for: .seconds(1.3))
                    await store.fetch()
					if store.isReady && !hasSetUpData {
						hasSetUpData = true
					}
                    hasLoaded = true
                }
        }
    }
}
