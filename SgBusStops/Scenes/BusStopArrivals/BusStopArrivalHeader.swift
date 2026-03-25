//
//  BusStopArrivalHeader.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import Models
import Pow
import Services
import SwiftUI
import UI

struct BusStopArrivalHeader: View {

	private let model: ArrivalRowViewModel
	init(_ model: ArrivalRowViewModel) {
		self.model = model
	}

	var body: some View {
		HStack(alignment: .lastTextBaseline, spacing: 16) {

			if let distance = model.item.arrival.nextBus?.coordinate?.distance(
				to: model.item.busStop
					.coordinate
			) {
				Text(
					"\(Image(systemName: "signpost.right.and.left.fill")) ⎯⎯⎯ \(distance.formatted(.number.precision(.fractionLength(1)))) km ⎯⎯⎯ \(Image(systemName: "bus"))"
				)
				.font(.caption2)

			}
			Spacer()
			Button {
				model.toggleFavourite()
			} label: {
				Image(systemName: "star")
					.foregroundStyle(
						model.isFavourite ? Color.yellow.gradient : Color.gray.gradient
					)
					.symbolVariant(model.isFavourite ? .fill : .none)
					.imageScale(model.isFavourite ? .medium : .small)
					.changeEffect(
						model.isFavourite
							? .spray {
								Group {
									Image(systemName: "star.fill").foregroundStyle(Color.red)
									Image(systemName: "star.fill").foregroundStyle(Color.blue)
									Image(systemName: "star.fill").foregroundStyle(Color.pink)
									Image(systemName: "star.fill").foregroundStyle(Color.orange)
								}
								.shadow(radius: 1)
							} : .spin,
						value: model.isFavourite,
						isEnabled: !model.isUpdatingFavourite,
					)
			}
			BusNumberText(model.item.arrival.serviceNo, .title1)
		}
		.alert(
			"Unable to Update Favourite",
			isPresented: Binding(
				get: { model.favouriteErrorMessage != nil },
				set: { isPresented in
					if !isPresented {
						model.favouriteErrorMessage = nil
					}
				},
			),
		) {
			Button("OK", role: .cancel) {
				model.favouriteErrorMessage = nil
			}
		} message: {
			Text(model.favouriteErrorMessage ?? "")
		}
	}
}
