//  NearbySheet.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import SgMaps
import SwiftUI
import Services
internal import _LocationEssentials
import Models

struct NearbySheet: View {

    @State private var viewModel: NearbySheetViewModel
    @AppStorage("nearbyDistance") private var distance: Double = 1000
    private let location: LocationResult
    @Environment(NavRouter.self) private var navRouter

    init(_ location: LocationResult) {
        self.location = location
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
                    BusStopCell(busStop: stop) { selected in
                        navRouter.push(.stopDetail(selected))
                    }
                }
            } footer: {
                if !viewModel.nearbyStops.isEmpty {
                    Text("\(distance, specifier: "%.0f" )m")
                        .font(.caption2)
                }
            }
        }
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
        .task(id: location) {
            await viewModel.fetchNearby(location: location, distance: distance)
        }
    }
}
