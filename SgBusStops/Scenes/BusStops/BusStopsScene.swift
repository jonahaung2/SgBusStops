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
    init() {
        _viewModel = .init(
            wrappedValue: .init(),
        )
    }

    var body: some View {
        List {
            ForEach(viewModel.groupedBusStops, id: \.roadName) { group in
                Section(group.roadName) {
                    ForEach(group.stops) { stop in
                        BusStopCell(busStop: stop)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search Bus Stops")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.fetchAll()
        }
    }
}
