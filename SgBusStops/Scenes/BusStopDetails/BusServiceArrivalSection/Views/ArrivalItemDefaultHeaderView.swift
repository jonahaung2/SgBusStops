//
//  ArrivalItemDefaultHeaderView.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 18/3/26.
//

import SwiftUI
import Models

struct ArrivalItemDefaultHeaderView: View {

	private let model: ArrivalItemViewModel

	init(_ model: ArrivalItemViewModel) {
		self.model = model
	}
    var body: some View {
		HStack(alignment: .lastTextBaseline) {
			Text(model.busServiceArrival.serviceNo)
				.font(.largeTitle.weight(.bold).width(.condensed))
				.lineHeight(.tight)
				.foregroundStyle(
					AngularGradient(
						colors: [.indigo, Color(uiColor: .label), .red],
						center: .center,
					)
					.opacity(0.8),
				)
			Spacer()
			Text(model.busServiceArrival.operatorCode.rawValue)
				.font(.footnote.weight(.semibold).smallCaps())
				.foregroundStyle(.secondary)

			Button {
				model.toggleFavourite()
			} label: {
				Image(systemName: "star")
					.foregroundStyle(
						model.isFavourite ? Color.orange.gradient : Color(
							uiColor: .lightGray).gradient
					)
					.symbolVariant(model.isFavourite ? .fill : .none)
			}
			.disabled(model.isUpdatingFavourite)
		}
		.sensoryFeedback(.selection, trigger: model.isFavourite)
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
