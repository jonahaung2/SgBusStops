//
//  FavouriteArrivalCell.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct FavouriteArrivalCell: View {

	let model: ArrivalRowViewModel
	@Environment(NavRouter.self) private var navRouter

	var body: some View {
		Section {
			VStack(alignment: .leading, spacing: 4) {
				ArrivalRow(model)
				if let distance = model.item.arrival.nextBus?.coordinate?.distance(
					to: model.item.busStop
						.coordinate
				) {
					Text(
						"\(Image(systemName: "signpost.right.and.left.fill"))⎯⎯ \(distance.formatted(.number.precision(.fractionLength(1)))) km ⎯⎯\(Image(systemName: "bus"))"
					)
					.font(.caption2)
					.foregroundStyle(.secondary)
				}
			}.transition(.identity)
		} header: {
			Button {
				navRouter.push(model.item.busStop)
			} label: {
				let busStop = model.item.busStop
				HStack(alignment: .center) {
					VStack(alignment: .leading, spacing: 0) {
						Text(busStop.desc)
							.font(.subheadline).fontWeight(.medium)
							.foregroundStyle(Color.primary)

						Text(busStop.roadName)
							.font(.caption2).italic()
							.foregroundStyle(.secondary)
					}
					.lineHeight(.leading(increase: 2))
					Spacer()
					BusNumberText(model.item.arrival.serviceNo, .title1)
				}
			}
		} footer: {
			ArrivalFooter(model: model)
		}
	}
}
struct FavouriteArrivalRowContent: View {
	let model: ArrivalRowViewModel

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			ArrivalRow(model)

			if let distance = model.item.arrival.nextBus?.coordinate?
				.distance(to: model.item.busStop.coordinate) {
				Text(
					"\(Image(systemName: "signpost.right.and.left.fill")) ⎯ \(distance.formatted(.number.precision(.fractionLength(1)))) km ⎯ \(Image(systemName: "bus"))"
				)
				.font(.caption2)
				.foregroundStyle(.secondary)
			}
		}
	}
}
struct FavouriteArrivalHeader: View {
	let model: ArrivalRowViewModel
	@Environment(NavRouter.self) private var navRouter

	var body: some View {
		HStack {
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
	}
}
