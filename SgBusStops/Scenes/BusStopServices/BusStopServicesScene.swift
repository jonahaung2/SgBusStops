//
//  BusStopServicesScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 25/3/26.
//

import SwiftUI
import Models
import Services
import UI
import  SgMaps
internal import _LocationEssentials

struct BusStopServicesScene: View {
	
	@State private var viewModel: BusStopServicesViewModel

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
					}
				}
			} else {
				ForEach(viewModel.serviceRoutes) { serviceRoute in
					BusServiceRouteCell(item: serviceRoute)
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
		.task {
			await viewModel.task()
		}
		.toolbarTitleDisplayMode(.large)
		.navigationTitle(viewModel.busStop.roadName)
		.navigationSubtitle(viewModel.busStop.desc)
    }
}
