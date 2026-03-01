//
//  BusStopDetailsViewModel.swift
//  SgBusStops
//
//  Created by Aung Ko Min on 19/2/26.
//

import Client
import Foundation
import Models
import Services

@Observable
@MainActor
final class BusStopDetailsViewModel {
    let busStop: BusStop
    var responses = [BusServicArrival]()
    var errorMessage: String?
    var isLoading = false
    @ObservationIgnored let busArrivalRepository = BusArrivalRepository(
        networkClient: NetworkClient(),
    )
    var hasViewLoaded = false
    private var task: Task<Void, Never>?

    init(busStop: BusStop) {
        self.busStop = busStop
    }

    func start() async {
        guard task == nil else {
            return
        }
        await fetchArrivalForBusStop()
        hasViewLoaded = true
        task = Task {
            for await _ in TimerSequence(every: .seconds(20)) {
                await fetchArrivalForBusStop()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    func fetchArrivalForBusStop() async {
        isLoading = true
        errorMessage = nil
        do {
            let arrival = try await busArrivalRepository.fetch(for: busStop.busStopCode)
            responses = arrival.services
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func fetchArrivalForBusService(busServiceNumber: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let arrival = try await busArrivalRepository.fetch(
                for: busStop.busStopCode,
                busServiceNumber: busServiceNumber,
            )
            for service in arrival.services {
                if let index = responses.firstIndex(where: { $0.id == service.id }) {
                    responses[index] = service
                } else {
                    responses.append(service)
                }
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
