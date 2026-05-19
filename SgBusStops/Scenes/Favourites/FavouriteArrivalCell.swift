//  FavouriteArrivalCell.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Models
import SwiftUI
import Services

struct FavouriteArrivalCell: View {

    let model: ArrivalRowViewModel
    @Environment(NavRouter.self) private var navRouter
    @Environment(BusStore.self) private var store

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                ArrivalRow(model)
                if let stop = store.busStop(for: model.arrival.busStopCode), let distance = model.arrival.arrival.nextBus?.coordinate?.distance(
                    to: stop.coordinate
                ) {
                    Text(
                        "\(Image(systemName: "signpost.right.and.left.fill")) ⎯ \(distance.formatted()) km ⎯\(Image(systemName: "bus"))"
                    )
                    .font(.caption2.width(.condensed))
                    .foregroundStyle(.secondary)
                }
            }.transition(.identity)
        } header: {
            if let stop = store.busStop(for: model.arrival.busStopCode) {
                Button {
                    navRouter.push(.stopDetail(stop))
                } label: {

                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(stop.desc)
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(Color.primary)

                            Text(stop.roadName)
                                .font(.caption2).italic()
                                .foregroundStyle(.secondary)
                        }
                        .lineHeight(.leading(increase: 2))
                        Spacer()
                        if let date = model.arrival.arrival.nextBus?.estimatedArrival {
                            let activity = LiveActivityModel(
                                busNumber: model.arrival.bus.busNumber,
                                stopCode: model.arrival.busStopCode,
                                stopName: stop.desc,
                                date: date
                            )
                            LiveActivityBadge(model: activity)
                        }
                        BusNumberText(model.arrival.arrival.serviceNo, .largeTitle)
                    }
                }
            }

        } footer: {
            ArrivalFooter(model: model)
        }
    }
}
