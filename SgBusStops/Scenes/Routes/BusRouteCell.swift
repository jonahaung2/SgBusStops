//  BusRouteCell.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

struct BusRouteCell: View {
    let route: BusRoutingInfo
    let busStop: Stop
    let rank: RouteRank
    @Environment(NavRouter.self) private var navRouter

    var body: some View {
        Button {
            navRouter.push(.stopArrivals(busStop.busStopCode))
        } label: {
            LabeledContent {
                Text(route.busStopCode).fontWidth(.condensed)
                    .foregroundStyle(.secondary)
            } label: {
                Text("\(busStop.desc)")
                    .font(.headline)
                Text(busStop.roadName)
                    .foregroundStyle(.secondary)

            }
            .multilineTextAlignment(.leading)
            .lineHeight(.multiple(factor: 1.3))
            .badgeProminence(rank == .past ? .decreased : .standard)
            .foregroundStyle(rank == .past ? .tertiary : .primary)
        }
    }
}
