//  StopBusRouteCell.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import UI
import Models
import SwiftUI
import Services

struct StopBusRouteCell: View {
    let stop: Stop
    let busRoute: StopBusRoutes
    @Environment(BusStore.self) private var store
    @Environment(NavRouter.self) private var navRouter
    var body: some View {
        let string: String = if let last = busRoute.route.routes.last, let lastStop = store.busStop(
            for: last.busStopCode
        ) {
            if let first = busRoute.route.routes.first, let firstStop = store.busStop(
                for: first.busStopCode
            ) {
                "\(firstStop.desc) - \(lastStop.desc)"
            } else {
                lastStop.desc
            }
        } else {
            if let first = busRoute.route.routes.first, let firstStop = store.busStop(
                for: first.busStopCode
            ) {
                firstStop.desc
            } else {
                "\(busRoute.route.routes.count) stops"
            }
        }
        let busNumber = Text(busRoute.route.busNumber).font(.custom("Impact", size: UIFont.preferredFont(forTextStyle: .title2).pointSize)).foregroundStyle(
            Color.indigo.mix(with: .primary, by: 0.3).gradient
        )
        let text = Text(string).font(.callout).foregroundStyle(.secondary).italic()

        Button {
            navRouter.push(.routesOfStop(StopBusRoutes(route: busRoute.route, stop: stop)))
        } label: {
            Text("\(busNumber)  \(text)")
                .lineHeight(.multiple(factor: 1.2))
                .multilineTextAlignment(.leading)

        }
    }
}
