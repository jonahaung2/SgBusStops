//
//  BusStopDetailsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import SgMaps
import SwiftUI
import UI
import Services

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
			} else if viewModel.arrivalItems.isEmpty {
				Section {
					ContentUnavailableView("No bus arrival yet", systemImage: "bus.fill")
				}
			} else {

				Section {

				} header: {
					VStack(alignment: .trailing, spacing: 4) {
						Text(viewModel.busStop.desc)
							.font(.title2).fontWeight(.semibold)
					}
					.frame(maxWidth: .infinity)
					.foregroundStyle(.primary)
				}

				ForEach(viewModel.arrivalItems) { model in
					BusServiceArrivalSection(model)
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				NavigationLink {
					AnimatedMap(
						[viewModel.busStop.mapItem],
						selection: viewModel.busStop.mapItem,
					)
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
		.toolbarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.busStop.roadName)
		.navigationSubtitle(viewModel.busStop.busStopCode)
	}
}
