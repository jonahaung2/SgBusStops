//  BusRoutesCell.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

struct BusRoutesCell: View {

    let route: BusRoutingInfo

    @Environment(BusStore.self) private var busStopStore
    @Environment(NavRouter.self) private var navRouter

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let stop = busStopStore.busStop(for: route.busStopCode) {
                BusStopCell(busStop: stop) { selection in
                    navRouter.push(.stopArrivals(selection.busStopCode))
                }
            } else {
                Button {
                    navRouter.push(.stopArrivals(route.busStopCode))
                } label: {
                    LabeledContent {
                        Text("\(route.distance.formatted()) km")
                    } label: {
                        Text(route.busStopCode)
                    }
                }
            }

        }
    }
}
