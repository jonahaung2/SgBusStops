//  LiveActivityViewModel.swift
//
//  Copyright © 2026 Aung Ko Min.
//

import Models
import SwiftUI
import Services
import ActivityKit

@MainActor
@Observable
final class LiveActivityViewModel: ViewModel {

    var current: LiveActivityModel?
    private var repeater: PreciseRepeater = .init()

    func start(model: LiveActivityModel) async {
        await endAll()
        current = model
        do {
            try await LiveActivityManager.start(model: model)
            await startObserving()
        } catch {
            showError(error)
        }
    }

    private func startObserving() async {
        await repeater.start(
            interval: .seconds(20),
            tolerance: .seconds(1),
            immediate: true,
            preventOverlap: true,
            operation: action
        )
    }

    private func action() async {
        guard let current else { return }
        if let arrival = try? await BusStopFetcher()
            .fetchArrivalForBusService(
                busServiceNumber: current.busNumber,
                busStopCode: current.stopCode
            ), let date = arrival.first?.nextBus?.estimatedArrival, date <= current.date
        {
            self.current?.date = date
            await LiveActivityManager
                .sync(
                    busNumber: current.busNumber,
                    busStopCode: current.stopCode,
                    arrivalTime: date
                )
        } else {
            await endAll()
        }
    }

    func endAll() async {
        await repeater.stop()
        await LiveActivityManager.endAll()
        current = nil
    }

    override init() {
        super.init()
        if let state = LiveActivityManager.activities.first?.content.state {
            current = .init(
                busNumber: state.busNumber,
                stopCode: state.busStopCode,
                stopName: state.stopName,
                date: state.arrivalTime
            )
        }
    }
}
