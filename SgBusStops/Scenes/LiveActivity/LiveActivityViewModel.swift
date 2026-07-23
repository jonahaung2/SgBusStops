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
        await repeater.stop()
        do {
            try await LiveActivityManager.start(model: model)
            current = model
            await startObserving()
        } catch {
            current = nil
            showError(error)
        }
    }

    func handleScenePhase(isActive: Bool) async {
        guard current != nil else { return }

        if isActive {
            await startObserving()
            await repeater.resume()
        } else {
            await repeater.pause()
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

        guard LiveActivityManager.isTracking(
            busNumber: current.busNumber,
            busStopCode: current.stopCode
        ) else {
            await endAll()
            return
        }

        do {
            let arrivals = try await BusStopFetcher().fetchArrivalForBusService(
                busServiceNumber: current.busNumber,
                busStopCode: current.stopCode
            )

            guard let date = arrivals.first?.nextBus?.estimatedArrival else {
                await endAll()
                return
            }

            self.current?.date = date
            await LiveActivityManager.sync(
                busNumber: current.busNumber,
                busStopCode: current.stopCode,
                arrivalTime: date
            )
        } catch is CancellationError {
            return
        } catch {
            return
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
