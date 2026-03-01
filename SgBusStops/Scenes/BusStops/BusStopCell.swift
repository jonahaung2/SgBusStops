//
//  BusStopCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Models
import SwiftUI
import UI

struct BusStopCell: View {
    let busStop: BusStop
    var body: some View {
        NavigationLink {
            BusStopDetailsScene(busStop)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(busStop.desc)
                        .font(.title3.weight(.medium))

                    Spacer()
                    BadgeView(busStop.busStopCode)
                        .font(.title2.width(.compressed).weight(.semibold))
                        .foregroundStyle(
                            AngularGradient(colors: [.indigo, .black, .red], center: .center),
                        )
                }
                Text(busStop.roadName)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }.navigationLinkIndicatorVisibility(.hidden)
    }
}
