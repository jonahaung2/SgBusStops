//  ArrivalRow.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Models
import SwiftUI
import Services

struct ArrivalRow: View {
    private let model: ArrivalRowViewModel

    @Environment(NavRouter.self) private var navRouter
    @Environment(BusStore.self) private var store
    init(_ model: ArrivalRowViewModel) {
        self.model = model
    }

    var body: some View {
        Grid(alignment: .centerLastTextBaseline, horizontalSpacing: 0) {
            GridRow(alignment: .lastTextBaseline) {
                ForEach(
                    Array(model.arrival.arrival.arrivals().enumerated()),
                    id: \.offset
                ) { index, arrival in
                    ArrivalColumn(
                        arrival: arrival,
                        rank: index + 1
                    )
                    .frame(maxWidth: .infinity)
                    .id(index)
                }
            }
        }
        ._onButtonGesture(
            pressing: { _ in

            },
            perform: {

                if let stop = store.busStop(for: model.arrival.busStopCode) {
                    navRouter
                        .push(
                            .routesOfStop(
                                .init(route: .init(bus: model.arrival.bus, stops: []), stop: stop)
                            )
                        )
                }

            }
        )
        .transition(.identity)
    }
}

extension BusArrival {
    func arrivals() -> [Arrival] {
        var arrivals = [Arrival]()
        if let nextBus { arrivals.append(nextBus) }
        if let nextBus2 { arrivals.append(nextBus2) }
        if let nextBus3 { arrivals.append(nextBus3) }
        return arrivals
    }
}
