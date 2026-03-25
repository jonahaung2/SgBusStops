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

struct BusStopArrivalsScene: View {

	@State private var viewModel: BusStopArrivalsViewModel

	init(_ busStop: BusStop) {
		_viewModel = .init(wrappedValue: .init(busStop: busStop))
	}

	var body: some View {
		List {
			if let errorMessage = viewModel.error {

				Section {
					ContentUnavailableView {
						Label(errorMessage.title, systemImage: errorMessage.imageName)
					} description: {
						Text(errorMessage.description)
					} actions: {
						Button("Retry") {
							Task {
								await viewModel.fetchArrivalForBusStop()
							}
						}
					}
				}
			} else {
				ForEach(viewModel.serviceRoutes) { serviceRoute in
					if let model = viewModel.arrivalItems.first(
						where: { $0.item.arrival.serviceNo == serviceRoute
							.serviceNo }) {
						BusStopArrivalSection(model)
					} else {
						BusServiceRouteCell(item: serviceRoute)
					}
				}
			}
		}.overlay {
			if viewModel.isLoading {
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
