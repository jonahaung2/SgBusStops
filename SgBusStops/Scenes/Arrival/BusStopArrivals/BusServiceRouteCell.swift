//
//  BusServiceRouteCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 25/3/26.
//

import SwiftUI
import Models
import Services
import UI

struct BusServiceRouteCell: View {

	let item: BusServiceRoute
	@Environment(BusStore.self) private var store
	@Environment(NavRouter.self) private var navRouter
    var body: some View {
		LabeledContent {
			Text("\(item.stops.count) stops")
				.italic()
				.foregroundStyle(.secondary)
		} label: {
			HStack(alignment: .bottom) {
				BusNumberText(item.serviceNo, .headline)
				Text("\(item.direction)")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}
		}._onButtonGesture { _ in

		} perform: {
			navRouter.push(item)
		}
    }
}
