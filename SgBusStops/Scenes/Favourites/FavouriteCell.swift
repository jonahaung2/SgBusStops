//  FavouriteCell.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Models
import SwiftUI
import Services

struct FavouriteCell: View {

    let item: FavouriteArrival
    @Environment(BusStore.self) private var store
    @Environment(NavRouter.self) private var navRouter

    var body: some View {
        if let busStop = store.busStop(for: item.busStopCode) {
            Button {
                if let busStop = store.busStop(for: item.busStopCode) {
                    navRouter.push(.stopDetail(busStop))
                }
            } label: {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(busStop.desc) \(Image(systemName: "moon.stars.fill"))")
                            .font(.subheadline).fontWeight(.medium)

                        Text(busStop.roadName)
                            .font(.caption2).italic()
                            .foregroundStyle(.secondary)

                    }
                    .lineHeight(.leading(increase: 2))
                    Spacer()
                    BusNumberText(item.busServiceNumber, .title1)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
