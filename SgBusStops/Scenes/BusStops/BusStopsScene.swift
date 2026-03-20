//
//  BusStopsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Models
import Services
import SgMaps
import SwiftUI
import UI

@MainActor
struct BusStopsScene: View {
	@State private var viewModel: BusStopsViewModel
	@Environment(BusStopStore.self) private var busStopStore

	init() {
		_viewModel = .init(
			wrappedValue: .init(),
		)
	}

	var body: some View {
		List {
			Section {
				NavigationLink {
					SgAreaMapView { area in
						print(area)
					}

				} label: {
					Label {
						Text("Area Map")
					} icon: {
						IconView {
							Image(systemName: "globe.asia.australia.fill")
						}
						.foregroundStyle(RandomShapeStyle.style(for: "globe.asia.australia.fill"))
					}
				}
				NavigationLink {
					SgMrtMapView { mrt in
						print(mrt)
					}

				} label: {
					Label {
						Text("MRT Map")
					} icon: {
						IconView {
							Image(systemName: "train.side.front.car")
						}
						.foregroundStyle(RandomShapeStyle.style(for: "train.side.front.car"))
					}
				}
			}
			ForEach(viewModel.groupedBusStops, id: \.roadName) { group in
				Section {
					ForEach(group.stops) { stop in
						BusStopCell(busStop: stop)
					}
				} header: {
					Text(group.roadName)
						.font(.subheadline.lowercaseSmallCaps().bold())
						.foregroundStyle(Color(uiColor: .label))
				}
			}
		}
		.animation(.default, value: viewModel.groupedBusStops.count)
		.listSectionIndexVisibility(.automatic)
		.searchable(text: $viewModel.searchText, prompt: "Search Bus Stops")
		.refreshable {
			await busStopStore.fetch()
			viewModel.items = busStopStore.busStops
		}
		.task {
			viewModel.items = busStopStore.busStops
		}
	}
}
