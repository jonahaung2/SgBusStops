//
//  ArrivalRow.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 20/3/26.
//


import Models
import SwiftUI
import UI

struct ArrivalRow: View {
    private let model: ArrivalRowViewModel

    init(_ model: ArrivalRowViewModel) {
        self.model = model
    }

    private var serviceArrival: BusServicArrival {
        model.item.arrival
    }

    var body: some View {
        Grid(alignment: .centerLastTextBaseline, horizontalSpacing: 0) {
            GridRow(alignment: .lastTextBaseline) {
                ForEach(
                    Array(model.item.arrival.arrivals().enumerated()),
                    id: \.offset,
                ) { index, arrival in
                    ArrivalColumn(
                        arrival: arrival,
                        rank: index + 1,
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .transition(.identity)
    }
}
