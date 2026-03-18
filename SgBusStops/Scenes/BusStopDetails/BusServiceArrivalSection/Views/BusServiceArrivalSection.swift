//
//  BusServiceArrivalSection.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Models
import SwiftUI
import UI

struct BusServiceArrivalSection: View {

    private let model: ArrivalItemViewModel

	init(_ model: ArrivalItemViewModel) {
		self.model = model
    }

    var body: some View {
        Section {
			BusServicArrivalCell(model)
        } header: {
			ArrivalItemDefaultHeaderView(model)
        }
    }
}
