//
//  BusArrivalMapViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/2/26.
//

import SwiftUI
internal import MapKit
import Models

@Observable
@MainActor
final class BusArrivalMapViewModel {
    var annotations: [MapAnnotationItem] = []
    let arrival: BusArrival
    func update(with newItems: [MapAnnotationItem]) {
        let oldSet = Set(annotations)
        let newSet = Set(newItems)

        if oldSet != newSet {
            annotations = newItems
        }
    }

    init(arrival: BusArrival) {
        self.arrival = arrival
    }

    func task() async {
        if let coordinate = arrival.coordinate {
            let item = MapAnnotationItem(
                id: arrival.id,
                coordinate: coordinate,
                title: arrival.arrivalDisplayString(),
            )
            update(with: [item])
        }
    }
}
