//  BusStopsScene.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Client
import Models
import SgMaps
import SwiftUI
import Services
internal import _LocationEssentials

enum DisplayType: String, Sendable, Hashable, Identifiable, CaseIterable {
    case busStops = "Bus Stops"
    case busses = "Busses"
    var id: String { rawValue }
}

@MainActor
struct BusStopsScene: View {

    @State private var viewModel: BusStopsViewModel
    @Environment(BusStore.self) private var busStopStore
    @Environment(NavRouter.self) private var navRouter
    @Environment(\.dismissSearch) private var dismissSearch

    init() {
        _viewModel = .init(
            wrappedValue: .init()
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
                        .foregroundStyle(Color.blue)
                    }
                }
                NavigationLink {
                    SgMrtMapView { mrt in

                    }
                } label: {
                    Label {
                        Text("MRT Map")
                    } icon: {
                        IconView {
                            Image(systemName: "train.side.front.car")
                        }
                        .foregroundStyle(Color.red)
                    }
                }
            }

            Section {
                Picker("Display Type", selection: $viewModel.displayType) {
                    ForEach(DisplayType.allCases) { each in
                        Text(each.rawValue)
                            .tag(each)
                    }
                } currentValueLabel: {
                    Text(viewModel.displayType.rawValue)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
            }
            switch viewModel.displayType {
            case .busStops:
                if viewModel.groupedBusStops.isEmpty, viewModel.searchText.isEmpty == false {
                    ContentUnavailableView.search
                }
                ForEach(viewModel.groupedBusStops, id: \.roadName) { group in
                    Section {
                        ForEach(group.stops) { stop in
                            BusStopCell(busStop: stop) { selection in
                                navRouter.push(.stopDetail(selection))
                            }
                        }
                    } header: {
                        Text(group.roadName)
                            .font(.title2.bold())
                            .foregroundStyle(Color.primary)
                    } footer: {
                        Text(group.stops.count.formatted() + " stops")
                    }
                    .id(group.roadName)
                }
            case .busses:
                if viewModel.routes.isEmpty, viewModel.searchText.isEmpty == false {
                    ContentUnavailableView.search
                }
                ForEach(viewModel.routes) { item in
                    Button {
                        navRouter.push(.busRoutes(item))
                    } label: {
                        LabeledContent {
                            item.bus.busOperator.badge.frame(height: 20)
                        } label: {
                            HStack(alignment: .top, spacing: 8) {
                                BusNumberText(item.bus.busNumber, .title3)
                                if item.direction != .inbound {
                                    Text("\(item.direction.rawValue.formatted())")
                                        .font(.caption2.bold())
                                        .italic()
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }.id(item.id)
                }
            }
        }
        .animation(
            .anticipate,
            value: viewModel.displayType == .busses ? viewModel.routes.count : viewModel
                .groupedBusStops.count
        )
        .ignoresSafeArea(.keyboard)
        .searchable(
            text: .init(get: { viewModel.searchText }, set: { viewModel.search($0) }),
            prompt: viewModel.displayType == .busStops ? "Search Bus Stops" : "Search Bus Number"
        )
        .refreshable {
            await busStopStore.fetch(forceRefresh: true)
            await viewModel.task()
        }
        .task(id: viewModel.displayType) {
            dismissSearch()
            await viewModel.task()
        }
    }
}
