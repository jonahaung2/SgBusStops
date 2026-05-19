//  BusServiceRouteScene.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

struct BusServiceRouteScene: View {

    @State private var viewModel: BusServiceRouteViewModel
    @Environment(BusStore.self) private var busStore

    init(busRoute: StopBusRoutes) {
        _viewModel = .init(
            wrappedValue: .init(busRoute: busRoute)
        )
    }

    var body: some View {
        List {
            if let error = viewModel.error {
                ContentUnavailableView(
                    error.title,
                    systemImage: error.imageName,
                    description: Text(error.description)
                )
            } else {
                if viewModel.routes.isEmpty == false {
                    Section {
                        ForEach(viewModel.routes, id: \.id) { route in
                            if let stop = busStore.busStop(for: route.busStopCode) {
                                BusRouteCell(
                                    route: route,
                                    busStop: stop,
                                    rank:
                                    .rank(
                                        for: route,
                                        routes: viewModel.routes,
                                        busStopCode: viewModel.busStop?.busStopCode
                                    )
                                )
                            }
                        }
                    }
                } else {
                    ZStack {
                        ProgressView().controlSize(.mini)
                    }.frame(maxWidth: .infinity)
                        .frame(height: 400)
                }
            }
        }
        .task {
            if viewModel.routes.isEmpty {
                await viewModel.task()
            }
        }

        .navigationTitle(viewModel.item.busNumber)
        .navigationSubtitle(
            viewModel.busStop?.desc ?? viewModel.item.direction.rawValue.formatted()
        )
    }
}

public enum RouteRank: Hashable {
    case past, current, upcoming

    static func rank(for route: BusRoutingInfo, routes: [BusRoutingInfo], busStopCode: String?)
        -> RouteRank
    {
        if busStopCode == nil {
            return .upcoming
        }
        if route.busStopCode == busStopCode {
            return .current
        }
        let position =
            routes.first(
                where: {
                    $0.busStopCode == busStopCode
                        && $0.serviceNo
                        == route.serviceNo
                }
            )?.stopSequence ?? 0
        return route.stopSequence < position ? .past : .upcoming
    }
}
