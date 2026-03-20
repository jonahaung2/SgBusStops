//
//  BusStopArrivalFooter.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 20/3/26.
//

import SwiftUI
import Services
import Models

struct ArrivalFooter: View {

	let model: ArrivalRowViewModel
	@Environment(BusStopStore.self) private var store

    var body: some View {
		HStack(alignment: .firstTextBaseline) {
			if let codeA = model.item.arrival.nextBus?.originCode,
			   let original = store.busStop(
				for: codeA,
			   )
			{
				if let code = model.item.arrival.nextBus?.destinationCode,
				   let destination = store.busStop(
					for: code,
				   )
				{
					Text(
						"\(original.desc) \(Image(systemName: "arrow.forward")) \(destination.desc)",
					)
					.font(.caption2)
					.italic()
				} else {
					Text(original.desc)
				}
			}
			Spacer()
			model.item.arrival.operatorCode.badge.frame(height: 10)
		}
    }
}
