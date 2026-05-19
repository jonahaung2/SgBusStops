//  BusStopArrivalSection.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Models
import SwiftUI
import Services

struct BusStopArrivalSection: View {
    private let model: ArrivalRowViewModel
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
