//  BusServiceArrivalMap.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
import CoreLocation
internal import MapKit
import UI
import Models

struct BusServiceArrivalMap: View {
    @State private var viewModel: BusServiceArrivalMapViewModel

    init(arrivatl: BusArrival) {
        _viewModel = .init(wrappedValue: .init(arrival: arrivatl))
    }

    var body: some View {
        LiveMapView(
            region: .init(
                center: CLLocationCoordinate2D(
                    latitude: 1.3521,
                    longitude: 103.8198
                ),
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ),
            annotations: $viewModel.annotations
        ) { item in
            RotatingBusMarker(title: item.title)
        }
        .task {
            viewModel.task()
        }
    }
}
