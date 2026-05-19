//  StopBussesSceneViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Client
import Models
import Services
import Foundation

@Observable
final class StopBussesSceneViewModel: ViewModel {

    let stop: Stop
    var busRoutes: [StopBusRoutes] = []

    init(_ stop: Stop) {
        self.stop = stop
    }

    func task() async {
        do {
            let busses = try await stop.busses()
            let stop = stop
            busRoutes = try await AsyncOrderedStream.mapOrdered(inputs: busses) { bus in
                if let route = try await bus.routes().buildServiceRoutes().first {
                    return StopBusRoutes(route: route, stop: stop)
                }
                return nil
            }.compactMap(\.self)
        } catch {
            showError(error)
        }
    }
}
