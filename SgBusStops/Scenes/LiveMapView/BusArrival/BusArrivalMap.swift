//
//  BusArrivalMap.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/2/26.
//

import CoreLocation
import SwiftUI
internal import MapKit
import Models
import UI

struct BusArrivalMap: View {
    @State private var viewModel: BusArrivalMapViewModel

    init(arrivatl: BusArrival) {
        _viewModel = .init(wrappedValue: .init(arrival: arrivatl))
    }

    var body: some View {
        LiveMapView(
            region: .init(
                center: CLLocationCoordinate2D(
                    latitude: 1.3521,
                    longitude: 103.8198,
                ),
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05),
            ),
            annotations: $viewModel.annotations,
        ) { item in
            RotatingBusMarker(title: item.title)
        }
        .task {
            await viewModel.task()
        }
    }
}
