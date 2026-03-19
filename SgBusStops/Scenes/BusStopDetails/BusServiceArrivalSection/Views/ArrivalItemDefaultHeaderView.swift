//
//  ArrivalItemDefaultHeaderView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import SwiftUI
import Models
import UI
import Services
import Pow

struct ArrivalItemDefaultHeaderView: View {

	private let model: ArrivalItemViewModel

	init(_ model: ArrivalItemViewModel) {
		self.model = model
	}
    var body: some View {
		HStack(alignment: .lastTextBaseline, spacing: 0) {
			BusNumberText(model.item.arrival.serviceNo, .title1)
			Spacer()
			Button {
				model.toggleFavourite()
			} label: {
				Image(systemName: "star")
					.foregroundStyle(
						model.isFavourite ? .primary : .quinary
					)
					.symbolRenderingMode(.multicolor)
					.symbolVariant(model.isFavourite ? .fill : .none)
					.changeEffect(
						model.isFavourite ? .spray {
							Image(systemName: "heart.fill").foregroundStyle(.red)
								.shadow(radius: 1)
								.font(.footnote.weight(.black))
						} : .shake,
						value: model.isFavourite, isEnabled: !model.isUpdatingFavourite
					)
			}
		}
		.alert(
			"Unable to Update Favourite",
			isPresented: Binding(
				get: { model.favouriteErrorMessage != nil },
				set: { isPresented in
					if !isPresented {
						model.favouriteErrorMessage = nil
					}
				}
			)
		) {
			Button("OK", role: .cancel) {
				model.favouriteErrorMessage = nil
			}
		} message: {
			Text(model.favouriteErrorMessage ?? "")
		}
    }
}
