//
//  FavouriteCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 23/3/26.
//

import SwiftUI
import Models
import Services
import UI

struct FavouriteCell: View {
	let item: FavouriteArrival
	@Environment(BusStore.self) private var store

	var body: some View {
		if let busStop = store.busStop(for: item.busStopCode) {
			HStack(alignment: .center) {
				VStack(alignment: .leading, spacing: 0) {
					Text(busStop.desc)
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
