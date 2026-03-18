//
//  BusStopCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import Services
import SwiftUI
import UI
internal import _LocationEssentials

struct BusStopCell: View {
    let busStop: BusStop
    @Environment(LocationService.self) private var locationService

    var body: some View {
        NavigationLink {
            BusStopDetailsScene(busStop)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(busStop.desc)
						.font(.title3.weight(.semibold))
                    if let currentLocation = locationService.location {
						let distance = busStop.distance(from: currentLocation.clLocation.coordinate)
                        Text("\(distance.formatted(.number.precision(.fractionLength(2)))) km")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    BadgeView(busStop.busStopCode)
						.font(.title2.width(.compressed).weight(.medium))
						.colorfulForeground()

                }
                Text(busStop.roadName)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }.navigationLinkIndicatorVisibility(.hidden)
    }
}
