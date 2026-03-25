//
//  BusServiceArrivalSection.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 5/3/26.
//

import Models
import Services
import SwiftUI
import UI

struct BusStopArrivalSection: View {
    private let model: ArrivalRowViewModel
    @Environment(BusStore.self) private var store

    init(_ model: ArrivalRowViewModel) {
        self.model = model
    }

    var body: some View {
        Section {
            ArrivalRow(model)
        } header: {
            BusStopArrivalHeader(model)
        } footer: {
			ArrivalFooter(model: model)
        }
    }
}
