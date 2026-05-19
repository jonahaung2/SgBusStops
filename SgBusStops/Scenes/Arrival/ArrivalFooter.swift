//  ArrivalFooter.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

struct ArrivalFooter: View {

    let model: ArrivalRowViewModel
    @Environment(BusStore.self) private var store

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if let codeA = model.arrival.arrival.nextBus?.originCode,
               let original = store.busStop(
                   for: codeA
               ) {
                if let code = model.arrival.arrival.nextBus?.destinationCode,
                   let destination = store.busStop(
                       for: code
                   ) {
                    Text(
                        "\(original.desc) \(Image(systemName: "arrow.forward")) \(destination.desc)"
                    )
                    .font(.caption2)
                    .italic()
                } else {
                    Text(original.desc)
                }
            }
            Spacer()
            model.arrival.arrival.operatorCode.badge.frame(height: 10)
        }
    }
}
