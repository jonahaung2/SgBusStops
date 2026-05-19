//  NavPath++.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services

public extension NavPath {
    @ViewBuilder
    func destiNation() -> some View {
        switch self {
        case let .busRoutes(item):
            BusRoutesScene(item)
        case let .stopDetail(stop):
            StopBussesScene(stop)
        case let .stopArrivals(stop):
            BusStopArrivalsScene(stop)
        case let .routesOfStop(item):
            BusServiceRouteScene(busRoute: item)
        }
    }
}
