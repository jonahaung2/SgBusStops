//
//  BusServiceArrivalMapViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/2/26.
//

import SwiftUI
internal import MapKit
import Models

@Observable
@MainActor
final class BusServiceArrivalMapViewModel {
    var annotations: [MapAnnotationItem] = []
    let arrival: BusServicArrival
    func update(with newItems: [MapAnnotationItem]) {
        let oldSet = Set(annotations)
        let newSet = Set(newItems)

        if oldSet != newSet {
            annotations = newItems
        }
    }

    init(arrival: BusServicArrival) {
        self.arrival = arrival
    }

    func task() async {
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
