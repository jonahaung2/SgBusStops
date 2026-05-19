//  BusServiceArrivalMapViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import SwiftUI
internal import MapKit
import Models

@Observable
@MainActor
final class BusServiceArrivalMapViewModel {
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

    func task() {
//        var items = [MapAnnotationItem]()
//        for each in arrival.arrivals() {
//            if let coordinate = each.coordinate {
//                let item = MapAnnotationItem(
//                    id: each.id,
//                    coordinate: coordinate,
//                    title: each.arrivalDisplayString(),
//                )
//                items.append(item)
//            }
//        }
//        update(with: items)
    }
}
