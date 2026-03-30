//
//  RootView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Services
import SwiftUI
import UI

struct RootView: View {

	@State private var store = BusStore()
	@State private var hasLoaded = false
	@State private var loadTrigger = UUID()
	@AppStorage("root_view_has_set_up_data") private var hasSetUpData: Bool = false

	var body: some View {
		if hasLoaded, store.isReady {
			MainTabView(store: store)
		} else {
			VStack(spacing: 16) {
				if hasSetUpData {
					Spacer()
				} else {
					BrandHeader(size: .incresed)
						.ignoresSafeArea()
						.backgroundExtensionEffect()
						.statusBarHidden(true)
				}
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
					Spacer()
				} else if store.isLoading && !hasSetUpData {
					ProgressView().controlSize(.mini)
					Text("Please wait while we set up the app for the first time...")
						.font(.caption)
						.foregroundStyle(.secondary)
						.padding(.horizontal)
				}
				Spacer()
			}
			.ignoresSafeArea()
			.task(id: loadTrigger) {
				if hasSetUpData {
					try? await Task.sleep(for: .seconds(1))
				}
				await store.fetch(forceRefresh: !hasSetUpData)
				if store.isReady && !hasSetUpData {
					hasSetUpData = true
				}
				hasLoaded = true
			}
		}
	}
}
