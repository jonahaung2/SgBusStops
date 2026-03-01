//
//  BusArrivalRow.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/2/26.
//

import Models
import SwiftUI

struct BusArrivalRow: View {
    let serviceArrival: BusServicArrival
    let arrival: BusArrival
    var body: some View {
        NavigationLink {
            BusArrivalMap(arrivatl: arrival)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(arrival.arrivalDisplayString())
                        .bold()
                    Spacer()
                    if let date = arrival.estimatedArrival {
                        Text(
                            date,
                            format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(),
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .italic()
                    }
                }
                HStack {
                    if let type = arrival.type {
                        Text(type.description)
                    }
                    if let load = arrival.load {
                        Text(load.description)
                    }
                }.font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
