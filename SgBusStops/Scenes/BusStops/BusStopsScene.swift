//
//  BusStopsScene.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Models
import Services
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
            ForEach(viewModel.groupedBusStops, id: \.roadName) { group in
				if let first = group.roadName.first {

					Section {
						ForEach(group.stops) { stop in
							BusStopCell(busStop: stop)
						}
					} header: {
						Text(group.roadName)
							.font(.subheadline.lowercaseSmallCaps().bold())
							.foregroundStyle(Color(uiColor: .label))
					}
					.sectionIndexLabel(Text(String(first)))
				}

            }
        }
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
