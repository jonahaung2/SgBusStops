//
//  SavedArrivalCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/3/26.
//

import SwiftUI
import Models
import Services
import UI

struct SavedArrivalCell: View {
	
	let model: ArrivalItemViewModel
	@Environment(BusStopStore.self) private var store
	@Environment(NavRouter.self) private var navRouter

    var body: some View {
		Section {
			BusServiceArrivalCell(model)
		} header: {
			HStack(alignment: .lastTextBaseline) {
				BusNumberText(model.item.arrival.serviceNo, .title1)
				Text(model.item.busStop.desc)
					.font(.footnote.weight(.medium))
			}
		} footer: {
			HStack(alignment: .firstTextBaseline) {
				if let codeA = model.item.arrival.nextBus?.originCode,
				   let original = store.busStop(
					for: codeA
				   )
				{
					if let code = model.item.arrival.nextBus?.destinationCode,
					   let destination = store.busStop(
						for: code
					   )
					{
						Text(
							"\(original.desc) \(Image(systemName: "arrow.right")) \(destination.desc)"
						)
						.font(.caption2)
						.italic()
					} else {
						Text(original.desc)
					}
				}
				Spacer()
				model.item.arrival.operatorCode.logo.frame(height: 10)
			}
		}
    }
}
