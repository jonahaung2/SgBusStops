//
//  NearByScene.swift
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

struct NearByScene: View {
	@State private var viewModel: NearbyStopsViewModel
	@AppStorage("nearbyDistance") private var distance: Double = 1000
	@Environment(LocationService.self) private var locationService
	@Environment(BusStopStore.self) private var busStopStore

	init() {
		_viewModel = .init(wrappedValue: .init())
	}

	var body: some View {
		List {
			Section {
				if let error = viewModel.error {
					ContentUnavailableView {
						Label(error.title, systemImage: error.imageName)
					} description: {
						Text(error.description)
					}
				}

				ForEach(viewModel.nearbyStops) { stop in
					BusStopCell(busStop: stop)
				}
			} header: {
				if let address = locationService.address {
					VStack(alignment: .center) {
						Text(address)
					}
					.font(.footnote.italic())
					.lineHeight(.tight)
				}
			} footer: {
				if !viewModel.nearbyStops.isEmpty {
					Text("\(distance, specifier: "%.0f" )m")
						.font(.caption2)
				}
			}
		}
		.animation(.interactiveSpring, value: locationService.address)
		.toolbar {
			if !viewModel.nearbyStops.isEmpty {
				ToolbarItem(placement: .primaryAction) {
					NavigationLink {
						AnimatedMap(items: viewModel.nearbyStops.map(\.mapItem)) { item in
							item.location.coordinate
						} title: { value in
							value.name
						}
					} label: {
						Image(systemName: "mappin.and.ellipse")
					}
				}
			}
		}
		.task(id: locationService.location) {
			if let location = locationService.location {
				viewModel.set(nearbyStops: await busStopStore
					.near(by: location, distance: distance))
			}
		}
		.refreshable {
			await locationService.startLocation()
		}
	}
}
