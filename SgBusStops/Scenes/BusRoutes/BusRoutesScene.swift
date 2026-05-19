//  BusRoutesScene.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

struct BusRoutesScene: View {

    @State private var viewModel: BusRoutesViewModel
    init(_ busRoutes: BusRoutes) {
        _viewModel = .init(wrappedValue: .init(busRoutes))
    }

    var body: some View {
        List {
            ForEach(viewModel.busRoutes.routes) { route in
                BusRoutesCell(route: route)
            }
        }
        .navigationTitle(viewModel.busRoutes.busNumber)
        .navigationSubtitle("Direction \(viewModel.busRoutes.direction.rawValue.formatted())")
        .task {
            await viewModel.task()
        }
    }
}
