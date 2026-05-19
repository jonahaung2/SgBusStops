//  NearByScene.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Models
import SgMaps
import SwiftUI
import Services
internal import _LocationEssentials

struct NearByScene: View {

    @State private var viewModel: NearbyStopsViewModel = .init()
    @AppStorage("nearbyDistance") private var distance: Double = 1000
    @Environment(LocationService.self) private var locationService
    @Environment(NavRouter.self) private var navRouter
    @Environment(LiveActivityViewModel.self) private var liveActivity

    @State private var controller: LocationAuthorizationController = .init()

    var body: some View {
        List {
            if controller.phase != .authorized {
                Section("Permission") {
                    LocationCheckerContentUnavailableView()
                }
            } else {
                Section {
                    if let error = viewModel.error {
                        ContentUnavailableView {
                            Label(error.title, systemImage: error.imageName)
                        } description: {
                            Text(error.description)
                        }
                    }

                    ForEach(viewModel.nearbyStops) { stop in
                        BusStopCell(busStop: stop) { selection in
                            navRouter.push(.stopArrivals(selection.busStopCode))
                        }
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
            if let model = liveActivity.current {
                ToolbarItem(placement: .principal) {
                    ArrivalActivityBadge(model: model)
                }
            }
        }
        .task(id: locationService.location) {
            if let location = locationService.location {
                await viewModel.fetchNearby(location: location, distance: distance)
            }
        }
        .refreshable {
            await locationService.startLocation()
        }
    }
}
