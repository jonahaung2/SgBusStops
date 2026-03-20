//
//  BusStopDetailsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import Services
import SgMaps
import SwiftUI
import UI
internal import _LocationEssentials

struct BusStopDetailsScene: View {

	@State private var viewModel: BusStopDetailsViewModel

	init(_ busStop: BusStop) {
		_viewModel = .init(wrappedValue: .init(busStop: busStop))
	}

	var body: some View {
		List {
			if let errorMessage = viewModel.errorMessage, viewModel.arrivalItems.isEmpty {
				Section {
					ContentUnavailableView {
						Label("Unable to Load Arrivals", systemImage: "exclamationmark.triangle")
					} description: {
						Text(errorMessage)
					} actions: {
						Button("Retry") {
							Task {
								await viewModel.fetchArrivalForBusStop()
							}
						}
					}
				}
			} else {
				ForEach(viewModel.arrivalItems) { model in
					BusStopArrivalSection(model)
				}
			}
		}.overlay {
			if viewModel.arrivalItems.isEmpty {
				ProgressView().controlSize(.mini)
			}
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				NavigationLink {
					AnimatedMap(items: [viewModel.busStop.mapItem]) { item in
						item.location.coordinate
					} title: { value in
						value.name
					}
				} label: {
					Image(systemName: "mappin.and.ellipse")
				}
			}
		}
		.repeatingTask {
			await viewModel.fetchArrivalForBusStop()
		}
		.refreshable {
			await viewModel.fetchArrivalForBusStop()
		}
		.toolbarTitleDisplayMode(.large)
		.navigationTitle(viewModel.busStop.roadName)
		.navigationSubtitle(viewModel.busStop.desc)
	}
}
