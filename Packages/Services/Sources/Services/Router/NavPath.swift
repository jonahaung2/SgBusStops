//  NavPath.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models

public enum NavPath: Sendable, Hashable {
    case busRoutes(_ item: BusRoutes)
    case stopDetail(_ item: Stop)
    case stopArrivals(_ code: String)
    case routesOfStop(_ item: StopBusRoutes)
}
