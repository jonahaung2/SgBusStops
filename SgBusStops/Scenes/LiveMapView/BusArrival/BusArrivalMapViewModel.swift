//  BusArrivalMapViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
internal import MapKit
import Models

@Observable
@MainActor
final class BusArrivalMapViewModel {
    var annotations: [MapAnnotationItem] = []
    let arrival: BusArrival.Arrival
    func update(with newItems: [MapAnnotationItem]) {
        let oldSet = Set(annotations)
        let newSet = Set(newItems)

        if oldSet != newSet {
            annotations = newItems
        }
    }

    init(arrival: BusArrival.Arrival) {
        self.arrival = arrival
    }

    func task() {
        if let coordinate = arrival.coordinate {
            let item = MapAnnotationItem(
                id: arrival.id,
                coordinate: coordinate,
                title: arrival.estimatedArrival?
                    .formatted(date: .omitted, time: .shortened) ?? arrival
                    .arrivalSeconds()?.description ?? "N.A"
            )
            update(with: [item])
        }
    }
}
