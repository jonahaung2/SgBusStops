//
//  SavedArrivalCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct SavedArrivalCell: View {

	let model: ArrivalRowViewModel
	@Environment(NavRouter.self) private var navRouter

	var body: some View {
		Section {
			ArrivalRow(model)
		} header: {
			HStack(alignment: .center) {
				Button {
					navRouter.push(model.item.busStop)
				} label: {
					VStack(alignment: .leading, spacing: 0) {
						Text(model.item.busStop.desc)
							.font(.subheadline).fontWeight(.medium)

						Text(model.item.busStop.roadName)
							.font(.caption2).italic()
							.foregroundStyle(.secondary)
					}
					.lineHeight(.leading(increase: 2))
				}
				Spacer()
				BusNumberText(model.item.arrival.serviceNo, .title1)
			}
		} footer: {
			ArrivalFooter(model: model)
		}
	}
}
