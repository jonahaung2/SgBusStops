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
            if viewModel.busArrivals.isEmpty == false {
				ForEach(viewModel.busArrivals) { model in
					BusServiceArrivalSection(model)
						.id(model.id)
                }
            }
            Section {
                ForEach(viewModel.nearbyStops) { stop in
                    BusStopCell(busStop: stop)
                        .id(stop.id)
                }
            } header: {
                VStack(alignment: .center) {
                    if let address = locationService.address {
                        Text(address)
                    } else if locationService.lastError == .timeout {
                        Text("Location request timed out. Pull to refresh to try again.")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.footnote.italic())
                .lineHeight(.tight)
            }
        }
        .toolbar {
            if !viewModel.nearbyStops.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AnimatedMap(
                            viewModel.nearbyStops.map(\.mapItem),
                            selection: viewModel.nearbyStops
                                .first!.mapItem,
                        )
                    } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                }
            }
        }
        .task(id: locationService.location) {
            if let location = locationService.location {
                viewModel.nearbyStops = await busStopStore
                    .near(by: location, distance: distance)
            }
        }
		.repeatingTask {
			await viewModel.fetchFavourites()
		}
        .refreshable {
            try? await Task.sleep(until: .now + .seconds(1))
            await locationService.startLocation()
            if let location = locationService.location {
                viewModel.nearbyStops = await busStopStore
                    .near(by: location, distance: distance)
            }
			await viewModel.fetchFavourites()
        }
    }
}
